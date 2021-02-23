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
      const albumURL = albumCover.src;

      fetch('https://localhost:8888/testing').then(response => {
        console.log(response);
      })

      // writeToFile(albumURL);
      albumCover = imageFileName(albumURL);

      safari.extension.dispatchMessage("Song Changed", { "title": title, "artist": artist, "albumCover": albumCover });
    }
  });
}


function writeToFile(albumURL) {
  fetch(albumURL).then(resp => resp.blob()).then(blob => {
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.style.display = 'none';
    a.href = url;
    // the filename you want
    a.download = `${imageFileName(url)}.jpeg`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    console.log('downloaded');
  })
  .catch(() => alert('oh no!'));


  // const path = `images/${imageFileName(url)}`;
  // fetch(url).then((response) => {
  //   responseToReadable(response).pipe(fs.createWriteStream(path));
  // });



  // axios.get(url, { responseType:'stream' }).then((res) => {
  //   res.data.pipe(fs.createWriteStream(path))
  //   .on('close', function() {
  //     console.log(`file with url ${url} written to path ${path}`);
  //   });
  // })
}

function imageFileName(url) {
  const startingIndex = url.indexOf('/images/') + 8;
  return url.substring(startingIndex);
}
//
// async function responseToReadable(response) {
//   const reader = response.body.getReader();
//   const rs = new Readable();
//   const result = await reader.read();
//   if (!result.done) {
//     rs.push(Buffer.from(result.value));
//   }
//   else {
//     rs.push(null);
//     return;
//   }
//   return rs;
// }
