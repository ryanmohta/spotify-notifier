document.addEventListener("DOMContentLoaded", function(event) {
  setTimeout(() => {
    // Initial target inner node
    var innerObserver = new MutationObserver(onMutated);
    var targetNodeInner = document.querySelector('.now-playing');
    var observerConfig = { attributes: true, childList: true, characterData: true };
    innerObserver.observe(targetNodeInner, observerConfig);

    var outerObserver = new MutationObserver((mutations) => {
      onMutated(mutations);
      var innerObserver = new MutationObserver(onMutated);
      var targetNodeInner = document.querySelector('.now-playing');
      var observerConfig = { attributes: true, childList: true, characterData: true };
      innerObserver.observe(targetNodeInner, observerConfig);
    });

    var targetNodeOuter = document.querySelector('.now-playing-bar__left');
    outerObserver.observe(targetNodeOuter, observerConfig);

  }, 5000);
});


function onMutated(mutations) {
  mutations.forEach(function(mutation) {
    let title = document.querySelector('.now-playing ._3773b711ac57b50550c9f80366888eab-scss');
    let artist = document.querySelector('.now-playing .b6d18e875efadd20e8d037931d535319-scss');
    let albumCover = document.querySelector('.now-playing ._64acb0e26fe0d9dff68a0e9725b2a920-scss');

    if (title !== null && artist !== null && albumCover !== null) {
      const data = {
        title: title.innerText,
        artist: artist.innerText,
        albumURL: albumCover.src
      };

      fetch('https://localhost:8888/update', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data),
      })
      .then(() => safari.extension.dispatchMessage("Song Changed"));
    }
  });
}
