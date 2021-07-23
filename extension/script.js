const SERVER_URL = 'https://spotify-notifier.herokuapp.com';
const OUTER_NODE = '.b51affc9f26a5c8f65a387abdd375bef-scss';
const INNER_NODE = '._116b05d7721c9dfb84bb69e8f4fc5e01-scss';

const TITLE_NODE = '._86f3bde5c3f38a2a37d03381c41acaf4-scss';
const ARTIST_NODE = '.f9ac49a03051d20affdc7135cfdbad3e-scss';
const ALBUM_COVER_NODE = '._64acb0e26fe0d9dff68a0e9725b2a920-scss';

document.addEventListener("DOMContentLoaded", function(event) {
  setTimeout(() => {
    // Initial target inner node
    var innerObserver = new MutationObserver(onMutated);
    var targetNodeInner = document.querySelector(INNER_NODE);
    var observerConfig = { attributes: true, childList: true, characterData: true };
    innerObserver.observe(targetNodeInner, observerConfig);

    var outerObserver = new MutationObserver((mutations) => {
      onMutated(mutations);
      var innerObserver = new MutationObserver(onMutated);
      var targetNodeInner = document.querySelector(INNER_NODE);
      var observerConfig = { attributes: true, childList: true, characterData: true };
      innerObserver.observe(targetNodeInner, observerConfig);
    });

    var targetNodeOuter = document.querySelector(OUTER_NODE);
    outerObserver.observe(targetNodeOuter, observerConfig);

  }, 5000);
});


function onMutated(mutations) {
  mutations.forEach(function(mutation) {
    let title = document.querySelector(`${INNER_NODE} ${TITLE_NODE}`);
    let artist = document.querySelector(`${INNER_NODE} ${ARTIST_NODE}`);
    let albumCover = document.querySelector(`${INNER_NODE} ${ALBUM_COVER_NODE}`);

    if (title !== null && artist !== null && albumCover !== null) {
      const data = {
        title: title.innerText,
        artist: artist.innerText,
        albumURL: albumCover.src
      };

      fetch(SERVER_URL + '/update', {
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
