var googlemap_controller = {
  browserSupportFlag : false,
  mypos : null,
  friends: [],
  map: null,
  setMyPosition : function(pos){
    this.mypos = pos;
    this.map.setCenter(pos);

    // position column of the form
    console.log(pos);
    window.document.getElementById("tweet_ll").value = pos.la+","+pos.Ja;
  },
  setIcon : function(friend_info){
    var iw = new google.maps.InfoWindow({content: friend_info.message}),
        marker = new google.maps.Marker({
          position: friend_info.pos,
          map: this.map,
          title: friend_info.name,
          icon: friend_info.image_url
        });
    google.maps.event.addListener(marker, "click", function(){
      iw.open(this.map, marker);
    });
  }
};

googlemap_controller.initialize = function() {
  var options = {
    zoom: 12,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }, i;
  this.map = new google.maps.Map(document.getElementById("map_canvas"), options);

  // Try W3C Geolocation (Preferred)
  if(navigator.geolocation) {
    this.browserSupportFlag = true;
    navigator.geolocation.getCurrentPosition(function(pos) {
      googlemap_controller.setMyPosition(new google.maps.LatLng(pos.coords.latitude,pos.coords.longitude));
    }, function() {
      handleNoGeolocation(this.browserSupportFlag);
    });

  // Try Google Gears Geolocation
  } else if (google.gears) {
    this.browserSupportFlag = true;
    var geo = google.gears.factory.create('beta.geolocation');
    geo.getCurrentPosition(function(position) {
      googlemap_controller.setMyPosition(new google.maps.LatLng(position.latitude,position.longitude));
    }, function() {
      handleNoGeolocation(this.browserSupportFlag);
    });
  // Browser doesn't support Geolocation
  } else {
    this.browserSupportFlag = false;
    handleNoGeolocation(this.browserSupportFlag);
  }

  while(this.friends.length){
    this.setIcon(this.friends.pop());
  }

  function handleNoGeolocation(errorFlag) {
    if (errorFlag == true) {
      alert("Geolocation service failed.");
    } else {
      alert("Your browser doesn't support geolocation. We've placed you in Siberia.");
    }
    map.setCenter(this.mypos);
  }
};


googlemap_controller.addFriend = function(friend_info){
  this.friends.push(friend_info);
};
