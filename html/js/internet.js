
let internet = document.querySelector("#internet-app");
let loginModal = document.getElementById("loginmodal");
let currentSite = "";
let homePageSites=null;


$(document).ready(function () {
  internetheader = internet.querySelector("header");
  internetheader.addEventListener("mousedown", () => {
    internetheader.classList.add("active");
    internetheader.addEventListener("mousemove", onDrag);
  });
  document.addEventListener("mouseup", (e) => {
    internetheader.classList.remove("active");
    internetheader.removeEventListener("mousemove", onDrag);
  });

  $('.appcontainer').on('click', '.website-home-icon', function(e){
    //check data
    e.preventDefault();
    $(".webpage-content").show();
    let targetSite = $(this).data("sitename");
    //load site targetsite
    console.log("load ", targetSite);
    currentSite = targetSite;
    $(".homepage-content").hide();
    $(`#${targetSite}-site`).show();
    $(".homepage-categories").hide();
    $(".search-content-container").hide();
    $("#internet_searchQueryInput").val("www.burgershot.com");
  });

  $(".appcontainer").on("click", ".searchHomePage", function(e){
    loadHomePage(homePageSites);
    $(".search-content-container").hide();
  });

  $('.webpage-content').on('click', '.hamburgermenubars', function(e){
    e.preventDefault();
    $(".hamburgermenu").css("display","block");
  });

  $('.hamburgermenu').on('click', '.exit', function(e){
    e.preventDefault();
    $(".hamburgermenu").css("display","none");
  });

  $('.container').on('click', '#submitform', function(e){
    e.preventDefault();
    //get data from forms
    let username = $("#formUsername").val();
    let password = $("#formPassword").val();
    
    $.post(`https://${GetParentResourceName()}/loginAttempt`, JSON.stringify({
      website: currentSite,
      username: username,
      pass: password,

    }));
  });

  $('#internet_search').on('click', '#internet_searchQuerySubmit', async function(e){
    e.preventDefault();
    $(".homepage-categories").hide();
    $(".homepage-content").hide();
    $(".webpage-content").hide();
    $(".search-content-container").show();
    let searchContent = $("#internet_searchQueryInput").val();
    if (searchContent != "") {
      let result = await $.post(
        `https://${GetParentResourceName()}/searchQuery`,
          JSON.stringify({
            query: searchContent,
          })
      );

      searchQueryContent(result);
    }
    
  });

  $("#internet_searchQueryInput").keydown(async function (e) {
    $(".homepage-categories").hide();
    $(".homepage-content").hide();
    $(".webpage-content").hide();
    $(".search-content-container").show();
    if (e.keyCode === 13) {
      let searchContent = $("#internet_searchQueryInput").val();
      if (searchContent != "") {
        let result = await $.post(
          `https://${GetParentResourceName()}/searchQuery`,
          JSON.stringify({
            query: searchContent,
          })
        );

        searchQueryContent(result);
      }
    }
  });


  //loadinternetApp();
                                                                                       
});

window.addEventListener("message", function (event) {
    switch (event.data.type) {
     case "loadHomePage":
        loadHomePage(event.data.data);
        break;
    }
  });

  window.onclick = function(event) {
    if (event.target == loginModal) {
      loginModal.style.display = "none";
    }
}

  function closeinternet() {
    removeIcon("internet");
  }

  function loadHomePage(data){
    $(".homepage-content").empty();
    let table = data;
    homePageSites = table;
    console.log(table);
    if(data!=null){
      $.each(table, function (index, value) {
        var newElement = `
        <div data-sitename=${value.sitename} class="website-home-icon">
          <img class="website-image" src="${value.img}">
        </div>
        `;
        console.log(value.sitename);
        $(".homepage-content").append(newElement);
        $(`#${value.sitename}-site`).hide();
        $(".homepage-categories").show();
      });
      $(".homepage-content").show();
    }
  }

  function searchQueryContent(searchResult){
    $(".search-content").empty();
    $.each(searchResult, function (index, value) {
      console.log(value.sitename);
      var newElement = `
      <div data-sitename=${value.sitename} style="display:inline-block;" class="website-home-icon">
        <img class="search-website-image" src="${value.sitedata.homeIcon}">
        <span>
          <div class="search-item-title">${value.sitename}</div><br>
          <div class="search-item-description">${value.sitedata.description}</div>
        </span>
      </div>
      `;
      console.log("add ", value.sitename);
      $(".search-content").append(newElement);
    });
    $(".search-content-container").show();
  }
  
