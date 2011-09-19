(function(){
  /*var mpq=[];mpq.push(["init","3a6377c8f0449457cd1cbd7688757d6b"]);(function(){var b,a,e,d,c;b=document.createElement("script");b.type="text/javascript";b.async=true;b.src=(document.location.protocol==="https:"?"https:":"http:")+"//api.mixpanel.com/site_media/js/api/mixpanel.js";a=document.getElementsByTagName("script")[0];a.parentNode.insertBefore(b,a);e=function(f){return function(){mpq.push([f].concat(Array.prototype.slice.call(arguments,0)))}};d=["init","track","track_links","track_forms","register","register_once","identify","name_tag","set_config"];for(c=0;c<d.length;c++){mpq[d[c]]=e(d[c])}})();
  
  window.mpq = mpq;
*/  
  //window.$TRACK = mpq;
  window.$TRACK = {
    track: function(){},
    name_tag: function(){}
    
  };
  //$TRACK.identify($ID)
})();
