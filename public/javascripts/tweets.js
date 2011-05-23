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

  $.getJSON(, function(data){
    var max = data.length, i = 0;
    console.dir(data);
    console.log(i, max);
    for( i = 0; i < max; i ++ ){
      console.log(data[i]);
      googlemap_controller.addFriend(data[i]);
    }
  });
  $.PeriodicalUpdater(
    {url:"/user/friend_tweets.js",
     type:"html",
     minTimeout:1000,
     maxTimeout:120000,
     multiplier: 2},
    function(data){
      googlemap_controller.
    });
});
