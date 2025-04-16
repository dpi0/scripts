// ==UserScript==
// @name         Youtube Video's Published Date
// @namespace    https://tampermonkey.net/
// @version      1.0
// @description  Show YouTube video's publishing date, best to have these 2 uBlock origin filters "www.youtube.com##span.yt-formatted-string.style-scope.bold:nth-of-type(3)" & "www.youtube.com###owner-sub-count"
// @author       dpi0
// @include      *://*youtube.com/*
// @grant        none
// @homepageURL https://github.com/dpi0/scripts/blob/main/greasyfork/youtube-video-published-date.js
// @originalhomepageURL https://greasyfork.org/en/scripts/423791-youtube-videos-publishing-date
// @supportURL  https://github.com/dpi0/scripts/issues
// @license      MIT
// ==/UserScript==

(function () {
    'use strict';

    const observer = new MutationObserver(() => {
        const infoStrings = document.querySelector('#info-strings');
        const subCount = document.querySelector('#owner-sub-count');
        const channelName = document.querySelector('#channel-name');

        if (infoStrings && subCount && channelName) {
            observer.disconnect(); // Stop observing once elements are found

            infoStrings.remove();
            subCount.after(infoStrings); // Move publishing date below sub count

            infoStrings.querySelectorAll('span').forEach(e => e.remove()); // Remove extra spans

            const computedStyle = window.getComputedStyle(channelName);
            const originalSize = parseFloat(computedStyle.fontSize); // Extract numeric font size
            const fontUnit = computedStyle.fontSize.replace(/[0-9.]/g, '') || 'px'; // Extract unit
            const reducedSize = `${originalSize * 0.9}${fontUnit}`; // 90% of channel name size

            infoStrings.style.fontSize = reducedSize;
            infoStrings.style.fontWeight = '510'; // Slightly heavier than normal
            infoStrings.style.color = computedStyle.color; // Match channel name color
        }
    });

    observer.observe(document, { childList: true, subtree: true }); // Watch for DOM changes
})();

