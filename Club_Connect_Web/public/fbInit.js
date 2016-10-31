window.fbAsyncInit = function() {
  FB.init({
    appId      : '982092358603170',
    xfbml      : true,
    version    : 'v2.8',
    status     : true,
  });
  FB.AppEvents.logPageView();
  FB.getLoginStatus(function(response) {
    if (response.status === 'connected') {
      renderEventList()
    }
    else{
      FB.login(function(response){
        if (response.status === 'connected') {
          renderEventList()
        }
      });
    }
  });
};

(function(d, s, id){
   var js, fjs = d.getElementsByTagName(s)[0];
   if (d.getElementById(id)) {return;}
   js = d.createElement(s); js.id = id;
  js.src = "https://connect.facebook.net/en_US/sdk.js";
   fjs.parentNode.insertBefore(js, fjs);
 }(document, 'script', 'facebook-jssdk'));

function myFacebookLogin() {
  FB.login();
}

function renderEventList() {
  FB.api(
    "/me/events",
    function (response) {
      if (response && !response.error) {
        var events=new Array(response.data.length)
        for(var i=0; i<response.data.length; i++ ){
          var event_data=new Array(3)
          event_data[0]=response.data[i]["name"]
          event_data[1]=response.data[i]["description"]
          event_data[2]=response.data[i]["start_time"]
      
          events[i]=event_data
        }
        var list=document.getElementById("event_list")

        for(var i=0;i<events.length;i++){
          var array=events[i]
          var sublist = document.createElement('ul');
          var liElem = document.createElement('li');   

          for(var j = 0; j < array.length; j++) {     
            var liElem2 = document.createElement('li');
            liElem2.appendChild(document.createTextNode(array[j]));
            sublist.appendChild(liElem2);  
          }

          var brElem = document.createElement('br')
          liElem.appendChild(sublist)
          list.appendChild(liElem)
          list.appendChild(brElem)
        }
      }
    },{scope: ''});
}