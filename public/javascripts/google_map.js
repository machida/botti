// Load this only in map.html

var googlemap_controller = {
  browserSupportFlag : false,
  mypos : null,
  friends: [],
  map: null,

  setMyPosition : function(pos){
    this.mypos = pos;
    this.map.setCenter(pos);
  },

  addFriend : function(info){
    var link = info.myself ? "" :
          '<a data-remote="true" href=/tweets/' + info.id + '/message">DM</a>',
        message = [info.user.name, ":", info.content, link, "("+info.time+")"].join(" "),
        iw = new google.maps.InfoWindow({content: message}),
        marker = new google.maps.Marker({
          position: new google.maps.LatLng(info.location.lat,info.location.lng),
          map: this.map,
          title: info.user.name,
          icon: info.user.image_url
        });
    console.log(info.myself);
    google.maps.event.addListener(marker, "click", function(){
      iw.open(this.map, marker);
    });
    this.markers.push(marker);
  },

  clearMarkers : function() {
    while( this.markers.length ) {
      this.markers.pop().setMap(null);
    }
  },

  initialize : function() {
    var options = {
      zoom: 14,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }, i;
    this.map = new google.maps.Map(document.getElementById("map_canvas"), options);
    this.markers = [];
    geoLoc(function(pos) { googlemap_controller.setMyPosition(pos); });
    while(this.friends.length){
      this.setIcon(this.friends.pop());
    }
  }
};

function geoLoc(callback){
  // Try W3C Geolocation (Preferred)
  if(navigator.geolocation) {
    this.browserSupportFlag = true;
    navigator.geolocation.getCurrentPosition(function(pos) {
      callback.call(null, new google.maps.LatLng(pos.coords.latitude,pos.coords.longitude));
    }, function() {
      handleNoGeolocation(this.browserSupportFlag);
    });

  // Try Google Gears Geolocation
  } else if (google.gears) {
    this.browserSupportFlag = true;
    var geo = google.gears.factory.create('beta.geolocation');
    geo.getCurrentPosition(function(pos) {
      callback.call(null, new google.maps.LatLng(position.latitude,position.longitude));
    }, function() {
      handleNoGeolocation(this.browserSupportFlag);
    });
  // Browser doesn't support Geolocation
  } else {
    this.browserSupportFlag = false;
    handleNoGeolocation(this.browserSupportFlag);
  }

  function handleNoGeolocation(errorFlag) {
    if (errorFlag == true) {
      alert("位置情報の取得に失敗しました。再度ためしてください。問題が解決しない場合は、環境をそえて@tomy_kairaまで連絡をおねがいします。");
    } else {
      alert("お使いのブラウザは位置情報を提供していません。このサービスの利用には位置情報の提供が必須です。");
    }
  }
}

$(document).ready(function(){googlemap_controller.initialize();});
