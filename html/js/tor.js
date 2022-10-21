
let tor = document.querySelector("#tor-app");


$(document).ready(function () {
  torheader = tor.querySelector("header");
  torheader.addEventListener("mousedown", () => {
    torheader.classList.add("active");
    torheader.addEventListener("mousemove", onDrag);
  });
  document.addEventListener("mouseup", (e) => {
    torheader.classList.remove("active");
    torheader.removeEventListener("mousemove", onDrag);
  });



  $('#tor_search').on('click', '#tor_searchQuerySubmit', async function(e){
    e.preventDefault();
    let searchContent = $("#tor_searchQueryInput").val();
    if (searchContent != "") {
      let result = await $.post(
        `https://${GetParentResourceName()}/searchAddress`,
          JSON.stringify({
            address: searchContent,
          })
      );

      loadPage(result);
    }
    
  });

  $("#tor_searchQueryInput").keydown(async function (e) {
    if (e.keyCode === 13) {
      let searchContent = $("#tor_searchQueryInput").val();
      if (searchContent != "") {
        let result = await $.post(
          `https://${GetParentResourceName()}/searchAddress`,
          JSON.stringify({
            address: searchContent,
          })
        );

        loadPage(result);
      }
    }
  });

  $('.website-store-content').on('click', '.website-store-item', async function(e){
    e.preventDefault();
    console.log("clicked add");
    let playerAdIndex = $(this).data("player");
    let localAdIndex = $(this).data("local");

    console.log(localAdIndex);
    console.log(playerAdIndex)

    let ad_data = await $.post(
      `https://${GetParentResourceName()}/getPostingData`,
      JSON.stringify({
        localIndex: localAdIndex,
        playerIndex: playerAdIndex,
      })
    );
    console.log("dat:", ad_data.title);
    $("#website-store-inspect-photo").attr("src", ad_data.imagelink);
    $("#website-store-inspect-title").html(ad_data.title);

    $("#website-store-inspect-sellername").html("Seller: anonymous174238");
    $("#website-store-inspect-price").html("Price: ₿",(ad_data.price).toFixed(2));
    $("#website-store-inspect-quantityleft").html(ad_data.quantity_left, " left");

    $(".website-store-inspect").show();
    $(".website-store-content").hide();
  });

  


  //loadtorApp();
                                                                                       
});

window.addEventListener("message", function (event) {
    switch (event.data.type) {
     case "loadBlackMarket":
        break;
      case "blackmarketitems":
        populateStoreContent(event.data.data);
        break
    }
  });



  async function closetor() {
    removeIcon("tor");
  }

  function getBlackMarketItems(){
    console.log("get market items");
    $.post(`https://${GetParentResourceName()}/getBlackMarketItems`, JSON.stringify({}));

  }

  function populateStoreContent(data){
    console.log("populating");
    let table = data;
    $(".website-store-content").empty();
    if (data!=null){
      $.each(table, function (index, value) {
        var newElement =``;
        if(value.localitem){
          newElement = `
          <div data-local=${value.index} class="website-store-item">
            <img class="store-image" src="${value.imagelink}">
            <div class="website-store-item-title">
              ${value.title}
            </div>
            <div class="website-store-item-price">
              ₿${(value.price).toFixed(2)}
            </div>
          </div>
          `;
        }
        else{
          newElement = `
          <div data-player=${value.index} class="website-store-item">
            <img class="store-image" src="${value.imagelink}">
            <div class="website-store-item-title">
              ${value.title}
            </div>
            <div class="website-store-item-price">
              ₿${(value.price).toFixed(2)}
            </div>
          </div>
          `;
        }
          
          $(".website-store-content").append(newElement);
      });
    }
  }

  function loadPage(data){
    //loads page or a 404
    $("#404-site").hide();
    $("#silkroad-site").hide();
    console.log(data[0]);
    if(data[0]){
      if(data[0].sitename=="slikroad"){
        $("#silkroad-site").show();
        getBlackMarketItems();
      }
    }
    else{
      //load a 404
      $("#404-site").show();
    }
  }
  