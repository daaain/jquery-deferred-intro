# jquery-deferred-intro

!SLIDE

# Deferred / Promise pattern using jQuery

Daniel Demmel | @daaain  
ustwo™ design studio | ustwo.co.uk

!SLIDE

# A convoluted example

![image](images/example.png)

[http://jsfiddle.net/dain/87uPV/3](http://jsfiddle.net/dain/87uPV/3)

!SLIDE

# Why?

## Asynchronous spaghetti

``` javascript
$.ajax({
  type: 'GET',
  url: 'http://www.html5rocks.com/en/tutorials/file/xhr2/',
  success: function(response) {
    var insertDiv1 = $('<div></div>');
    insertDiv1.html($(response).find('section').html());
    $.ajax({
      type: 'GET',
      url: 'http://www.html5rocks.com/en/tutorials/audio/scheduling/',
      success: function(response) {
        var insertDiv2 = $('<div></div>');
        insertDiv2.html($(response).find('section').html());
        $('body').append(insertDiv1, '<hr/>', insertDiv2);
              } 
    });
  } 
});
```

!SLIDE

## Timing

``` javascript
$(document).ready(function () {
  $.ajax({
    type: 'GET',
    url: 'http://www.html5rocks.com/en/tutorials/file/xhr2/',
    success: function(response) {
      var insertDiv1 = $('<div></div>');
      insertDiv1.html($(response).find('section').html());
      $.ajax({
        type: 'GET',
        url: 'http://www.html5rocks.com/en/tutorials/audio/scheduling/',
        success: function(response) {
          var insertDiv2 = $('<div></div>');
          insertDiv2.html($(response).find('section').html());
          $('body').append(insertDiv1, '<hr/>', insertDiv2);
        }
      });
    }
  });
});
```

!SLIDE

# What?

## Deferred

* A proxy for an asynchronous, future event
* Has an interface for getting `resolve()`d or `reject()`ed
* Starts in `pending` state, can only be finished once
* Calls listeners immediately (but always async) once resolved

!SLIDE

## Promise

* Allows listening and state inspection (using `state()`), but completely immutable so no interface for resolution
* Basic (jQuery specific) listeners are `done()` and `fail()`
* Can be chained with `then()` (used to be `pipe()`)
* Can be grouped and processed using `$.when()`

!SLIDE

# How?

## Canonical Deferred

Setting up a listener and triggering it with resolve

``` javascript
var deferred = $.Deferred();

deferred.done(function(value) {
   alert(value);
});

deferred.resolve("hello world");
```

!SLIDE

## Canonical Deferred post-resolve

A resolved Deferred will still trigger the callback

``` javascript
var deferred = $.Deferred();

deferred.resolve("hello world");

deferred.done(function(value) {
   alert(value);
});
```

!SLIDE

## Canonical Promise + When

Return a Promise from a method and attach a listener to it (can have more than one)

``` javascript
function getPromise() {
  var deferred = $.Deferred();
  
  setTimeout(function(){
    deferred.resolve("hurray");
  }, 1000);
  
  return deferred.promise();
}

$.when( getPromise() ).done(function(value) {
   alert(value);
});
```

!SLIDE

## Untangle our example

Create a Promise for DOM ready and the two AJAX requests and wait for all of them to be fulfilled

``` javascript
function getReady() {
  var deferredReady = $.Deferred();
  $(document).ready(function() {
    deferredReady.resolve();
  });
  return deferredReady.promise();
}

var firstRequest = $.ajax({ url: 'http://www.html5rocks.com/en/tutorials/file/xhr2/' }),
    secondRequest = $.ajax({ url: 'http://www.html5rocks.com/en/tutorials/audio/scheduling/' });

$.when( getReady(), firstRequest, secondRequest
).done( function( readyResponse, firstResponse, secondResponse ) {
  var insertDiv1 = $('<div></div>');
  insertDiv1.html($(firstResponse[0]).find('section').html());
  var insertDiv2 = $('<div></div>');
  insertDiv2.html($(secondResponse[0]).find('section').html());
  $('body').append(insertDiv1, '<hr/>', insertDiv2);
});
```

!SLIDE

## Another solution

The AJAX request can be already fired off while we wait for the DOM (using chained listeners with `then()`)

``` javascript
function getReady() {
  var deferredReady = $.Deferred();
  $(document).ready(function() {
    deferredReady.resolve();
  });
  return deferredReady.promise();
}

var firstRequest = $.ajax({ url: 'http://www.html5rocks.com/en/tutorials/file/xhr2/' }),
    secondRequest = $.ajax({ url: 'http://www.html5rocks.com/en/tutorials/audio/scheduling/' }),
    firstDiv,
    secondDiv;

$.when( firstRequest, secondRequest
).then( function( firstResponse, secondResponse ) {
  firstDiv = $('<div></div>').html($(firstResponse[0]).find('section').html());
  secondDiv = $('<div></div>').html($(secondResponse[0]).find('section').html());
  return getReady();
}).done( function( readyResponse, firstResponse, secondResponse ) {
  $('body').append(firstDiv, '<hr/>', secondDiv);
});
```

!SLIDE

## Dealing with rejection

When a Promise gets `reject()`ed it will immediately cascade down the `then()` chain

``` javascript
getTweetsFor("domenic") // promise-returning function
  .then(function (tweets) {
    var shortUrls = parseTweetsForUrls(tweets);
    var mostRecentShortUrl = shortUrls[0];
    return expandUrlUsingTwitterApi(mostRecentShortUrl); // promise-returning function
  })
  .then(httpGet) // promise-returning function
  .then(
    function (responseBody) {
      console.log("Most recent link text:", responseBody);
    },
    function (error) {
      console.error("Error with the twitterverse:", error);
    }
  );
```

Example from [Domenic Denicola's blog post "You're Missing the Point of Promises"](http://domenic.me/2012/10/14/youre-missing-the-point-of-promises/), go and read it now!

!SLIDE

# More?

## When to use `then()` and `done()`

* `then()` is chainable, but is less performant as it has to create a new Promise to return.
* `done()` is a simple callback and can register multiple handlers with it, but doesn't handle failure (you'll need to attach a `fail()` too).
* So: use `then()`s mid-chain and close it off with `done()` and `fail()`.

!SLIDE

# More?

* For long requests use `notify()` and `progress()`
* Use `always()` for catching all outcomes
* You can insert transformations into the `then()` chain
``` javascript
$.when( { testing: 123 } ).done(
  function(x) { alert(x.testing); } /* alerts "123" */
);
```
* jQuery is not the only one, see [Promises/A spec](http://wiki.commonjs.org/wiki/Promises/A) and the clarified [Promises/A+ spec](http://promises-aplus.github.com/promises-spec/)
* If you're not already using jQuery then [Q](https://github.com/kriskowal/q), [rsvp.js](https://github.com/tildeio/rsvp.js) or [when](https://github.com/cujojs/when) are better with interoperability by fully adhering to the specs.

!SLIDE

# Even more?

* This pattern is not limited to Javascript, in fact [Futures / Promises](http://en.wikipedia.org/wiki/Futures_and_promises) pattern was first invented in 1976 as Eventual
* For Android you should look at [Android Deferred Object](https://github.com/CodeAndMagic/android-deferred-object) and [JDeferred](https://github.com/jdeferred/jdeferred)
* For iOS try [HLDeferred-objc](https://github.com/heavylifters/HLDeferred-objc) and [Objc-promise](https://github.com/mproberts/objc-promise) or if you also need Observers take a look at Github's [ReactiveCocoa](https://github.com/blog/1107-reactivecocoa-for-a-better-world)