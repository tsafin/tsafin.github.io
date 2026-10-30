// Off Canvas Sliding
$(document).ready(function(){
  function setMenu(open) {
    $('#js-menu, #js-menu-screen').toggleClass('is-visible', open);
    $('#js-menu-trigger').toggleClass('slide close', open);
    $('#js-menu-trigger').attr({
      'aria-expanded': open,
      'aria-label': open ? 'Close navigation' : 'Open navigation'
    });
    $('#js-menu').attr('aria-hidden', !open);
    $('#js-body').toggleClass('no-scroll', open);
  }

  $('#js-menu-trigger,#js-menu-screen').on('click', function(e){
    setMenu(!$('#js-menu').hasClass('is-visible'));
    e.preventDefault();
  });

  $('#js-menu a').on('click', function(){
    setMenu(false);
  });

  $(document).on('keydown', function(e){
    if (e.key === 'Escape') {
      setMenu(false);
    }
  });
});

// FitVids
$(document).ready(function(){
	// Target your .container, .wrapper, .post, etc.
	$("#main").fitVids();
});

// Table of Contents title. Change text to localize
$("#markdown-toc").prepend("<li><h6>{{ site.data.messages.locales[site.locale].overview }}</h6></li>");
