// ==UserScript==
// @name         YouTube Hotkeys
// @namespace    Violentmonkey Scripts
// @version      1.0
// @description  Custom hotkeys for YouTube
// @author       dpi0
// @include      *://*.youtube.com/*
// @grant        none
// @homepageURL https://github.com/dpi0/scripts/blob/main/greasyfork/youtube-hotkeys.js
// @supportURL  https://github.com/dpi0/scripts/issues
// @license     MIT
// ==/UserScript==

(function () {
    'use strict';

    // Define hotkeys: { key, shift, action }
    const hotkeys = [
        { key: 'h', shift: false, action: () => window.location.href = 'https://youtube.com' },
        { key: 'S', shift: true,  action: () => window.location.href = 'https://youtube.com/feed/subscriptions' },
        { key: 'T', shift: true,  action: () => window.location.href = 'https://youtube.com/feed/trending' },
        { key: 'w', shift: false, action: () => window.location.href = 'https://youtube.com/playlist?list=WL' },
        { key: '/', shift: false, action: () => document.querySelector('input#search')?.focus() },
        { key: '0', shift: false, action: () => window.scrollTo({ top: 0, behavior: 'smooth' }) }
    ];

    window.addEventListener('keydown', function (e) {
        if (
            !e.ctrlKey && !e.metaKey && !e.altKey &&
            !['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)
        ) {
            const match = hotkeys.find(hk => 
                hk.key.toLowerCase() === e.key.toLowerCase() &&
                (!!hk.shift === e.shiftKey)
            );
            if (match) match.action();
        }
    }, true);
})();
