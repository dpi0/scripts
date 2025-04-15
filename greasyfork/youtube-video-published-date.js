// ==UserScript==
// @name         Youtube Video's Published Date
// @namespace    https://tampermonkey.net/
// @version      1.0
// @description  Show YouTube video's publishing date
// @author       dpi0
// @include      *://*youtube.com/*
// @grant        none
// @homepageURL https://github.com/dpi0/scripts/blob/main/greasyfork/youtube-video-published-date.js
// @originalhomepageURL https://greasyfork.org/en/scripts/423791-youtube-videos-publishing-date
// @supportURL  https://github.com/dpi0/scripts/issues
// @license      MIT
// ==/UserScript==

(function() {
    'use strict';

    const observer = new MutationObserver(() => {
        const infoStrings = document.querySelector('#info-strings');
        const subCount = document.querySelector('#owner-sub-count');
        if (infoStrings && subCount) {
            observer.disconnect();

            // Move the publishing date below the sub count
            infoStrings.remove();
            subCount.after(infoStrings);

            // Remove extra spans and apply styles
            infoStrings.querySelectorAll('span').forEach(e => e.remove());

            const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            infoStrings.style.fontSize = '15px';
            infoStrings.style.fontWeight = '540';
            infoStrings.style.color = isDark ? '#f1f1f1' : '#0f0f0f';
        }
    });

    observer.observe(document, { childList: true, subtree: true });
})();
