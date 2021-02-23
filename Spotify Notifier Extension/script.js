import fs from 'fs';
import axios from 'axios';

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
      title = title.innerText;
      artist = artist.innerText;
      albumURL = albumCover.src;

      writeToFile(albumURL);
      albumCover = imageFileName(albumURL);

      safari.extension.dispatchMessage("Song Changed", { "title": title, "artist": artist, "albumCover": albumCover });
    }
  });
}


function writeToFile(url) {
  const path = `images/${imageFileName(url)}`;
  axios.get(url, { responseType:'stream' }).then((res) => {
    res.data.pipe(fs.createWriteStream(path))
    .on('close', function() {
      console.log(`file with url ${url} written to path ${path}`);
    });
  })
}

function imageFileName(url) {
  const startingIndex = url.indexOf('/images/') + 8;
  return url.substring(startingIndex);
}
