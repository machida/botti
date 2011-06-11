// Tweeting related scripts


function update(){
  $.getJSON("/user/friend_tweets.js", function(data){
    var i = 0, length = data.length;

    // 既存のアイテムを削除
    googlemap_controller.clearMarkers();
    for (;i < length; i++) {
      googlemap_controller.addFriend(data[i]);
    }
  });
}

function displayError(data) {
  $.each(["notice", "alert"], function(idx, attr) {
    $("." + attr).detach();
    if ( data[attr] ) {
      $("#header").after('<p class="'+attr+'">'+data[attr]+'</p>');
    }
  } );
}

$(document).ready( function() {
  $( "#new_tweet" ).bind("ajax:before", function() {
      if ( $( "#tweet_ll" ).val() == "" ) {
        geoLoc( function(pos) {

          // remove paren
          var str = pos.toString();
          $( "#tweet_ll" ).val( str.substr( 1, str.length-2 ) );
          $( "#new_tweet" ).submit();
          $( "#tweet_content" ).val("");
        });
        return false;
      }
    })
    .bind( "ajax:success", function(ev, data, status, xhr) {
      displayError(data);
      update();
    });

  $( "a[data-remote]" )
    .live( "ajax:success", function(ev, data, status, xhr){
      if (typeof data === "string") {
        $("#message").html(data);
        $( "#message_form" )
          .bind( "ajax:success", function(ev, data, status, xhr) {
            if ( !data.alert ) { // success
              $( "#message" ).html("");
            }
            displayError(data);
          });
      } else { // error
        displayError(data);
      }
      return false;
    });

  update(); // Initial update
  var int_id = setInterval( update, 60000 ); 
});
