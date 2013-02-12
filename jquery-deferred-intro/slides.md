# jquery-deferred-intro

!SLIDE

# jQuery Deferred / Promise

Daniel Demmel | @daaain  
ustwo™ design studio | ustwo.co.uk

!SLIDE

# A convoluted example

![image](images/example.png)

`http://jsfiddle.net/dain/87uPV/3`

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

# Why?

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
* Calls listeners immediately (still async) once resolved

!SLIDE

# What?

## Promise

* Allows listening and state inspection,  
but no interface for resolution
* Basic listeners are `done()` and `fail()`
* Can be chained with `then()` (used to be `pipe()`)
* Can be grouped and processed using `$.when()`

!SLIDE

# How?

## Canonical Deferred

``` javascript
var deferred = $.Deferred();

deferred.done(function(value) {
   alert(value);
});

deferred.resolve("hello world");
```

This also works:

``` javascript
var deferred = $.Deferred();

deferred.resolve("hello world");

deferred.done(function(value) {
   alert(value);
});
```

!SLIDE

# How?

## Canonical Promise + When

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

# How?

## Untangle our example

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

# How?

## Another solution

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

# More?

* `notify()` and `progress()`
* `reject()` and failure filters
* transformations
``` javascript
$.when( { testing: 123 } ).done(
  function(x) { alert(x.testing); } /* alerts "123" */
);
```
* jQuery is not the only one, see [Promises/A spec](http://wiki.commonjs.org/wiki/Promises/A)
* Dig deeper before [you miss the point](http://domenic.me/2012/10/14/youre-missing-the-point-of-promises/) :)