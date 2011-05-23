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

  update(); // Initial update
  var int_id = setInterval( update, 60000 );
  setTimeout( googlemap_controller.clearMarkers, 10000 );

  function update(){
    $.getJSON("/user/friend_tweets.js", function(data){
      var max = data.length, i = 0;

      // 既存のアイテムを削除

      for( i = 0; i < max; i ++ ){
        googlemap_controller.addFriend(data[i]);
      }
    });
  }
  
});
