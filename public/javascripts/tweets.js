$(document).ready( function() {
  $( "#new_tweet" ).bind("ajax:before", function() {
      if ( $( "#tweet_ll" ).val() == "" ) {
        geoLoc( function(pos) {

          // remove paren
          var str = pos.toString();
          $( "#tweet_ll" ).val( str.substr( 1, str.length-2 ) );
          $( "#new_tweet" ).submit();
        });
        return false;
      }
    })
    .bind( "ajax:success", function(ev, data, status, xhr) {
      $.each(["notice", "alert"], function(idx, attr) {
        if ( data[attr] ) {
          if ( $("." + attr).length > 0 ) {
            $("." + attr).text( data[attr] );
          } else {
            $("#header").after('<p class="'+attr+'">'+data[attr]+'</p>');
          }
        }
      } );
    });
});
