document.addEventListener("DOMContentLoaded", function(event) {
    setTimeout(() => {
        var observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                let title = document.querySelector('.now-playing ._3773b711ac57b50550c9f80366888eab-scss');
                let artist = document.querySelector('.now-playing .b6d18e875efadd20e8d037931d535319-scss');
                let albumCover = document.querySelector('.now-playing ._64acb0e26fe0d9dff68a0e9725b2a920-scss');
                
                if (title !== null && artist !== null && albumCover !== null) {
                    title = title.innerText;
                    artist = artist.innerText;
                    albumCover = albumCover.src;
                    
                    safari.extension.dispatchMessage("Song Changed", { "title": title, "artist": artist, "albumCover": albumCover });
                }

            });
        });
         
        // Notify me of everything!
        var observerConfig = {
            attributes: true,
            childList: true,
            characterData: true
        };
         
        // Node, config
        // In this case we'll listen to all changes to body and child nodes
        var targetNode = document.querySelector('.now-playing-bar__left');
        observer.observe(targetNode, observerConfig);
    }, 5000);
});
