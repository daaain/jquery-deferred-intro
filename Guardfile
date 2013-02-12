# disabling guard console
interactor :off

guard 'shell' do
  watch(%r{jquery-deferred-intro/slides.md}) do |m|
    system("(cd jquery-deferred-intro; keydown slides slides.md)")
  end
end

guard 'livereload' do
  watch(%r{jquery-deferred-intro})
end