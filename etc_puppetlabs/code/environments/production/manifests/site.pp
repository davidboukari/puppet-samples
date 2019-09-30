
node default{
  notify{ 'This is the production branch':}
  
  #class{ backup::info:
  #
  #}
  
   class{ info_sys::task: 

   }
  

}


