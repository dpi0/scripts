// ==UserScript==
// @name         YouTube Hotkeys
// @namespace    Violentmonkey Scripts
// @version      1.0
// @description  Custom hotkeys for YouTube
// @author       dpi0
// @include      *://*.youtube.com/*
// @match        https://www.youtube.com/*
// @match        https://youtube.com/*
// @grant        none
// @homepageURL https://github.com/dpi0/scripts/blob/main/greasyfork/youtube-hotkeys.js
// @supportURL  https://github.com/dpi0/scripts/issues
// @license     MIT
// ==/UserScript==

(function() {
    'use strict';

    // Default key bindings - these can be customized below
    const DEFAULT_KEY_BINDINGS = {
        'a': navigateToChannelVideos,          // Navigate to channel videos
        'q': navigateToChannelPlaylists,       // Navigate to channel playlists
        'E': navigateToHistory,                // Navigate to history
        'w': navigateToWatchLater,             // Navigate to watch later
        'A': navigateToLikedVideos,            // Navigate to liked videos
        // 'C': navigateToHome is removed as requested
        'S': navigateToSubscriptions,          // Navigate to subscriptions
        'T': navigateToTrending,               // Navigate to trending
        '/': focusSearchBar,                   // Focus search bar
        'H': clickNextButton,                  // Click next video button
        'G': clickPrevButton,                  // Click previous video button
        'e': saveToPlaylist,                   // Save current video to playlist
        'u': saveToWatchLater,                 // Save current video to watch later
        'y': copyVideoUrlWithTimestamp,        // Copy video URL with timestamp
        'Tab': toggleSidebar,                  // Toggle sidebar
    };

    // CONFIGURATION - Edit this object to customize your key bindings
    const KEY_BINDINGS = DEFAULT_KEY_BINDINGS;

    // Utility Functions
    function getChannelInfo() {
        // First try: Check if we're on a watch page
        if (window.location.pathname.startsWith('/watch')) {
            // Try to get channel link from video owner
            const ownerLinks = document.querySelectorAll('#owner #channel-name a, #top-row ytd-channel-name a');
            if (ownerLinks.length > 0) {
                return ownerLinks[0].href;
            }
        }

        // Second try: Check if we're already on a channel page
        if (window.location.pathname.includes('/channel/') || window.location.pathname.includes('/@')) {
            // Get the base channel URL without /videos or /playlists
            const baseUrl = window.location.href.split('/').slice(0, -1).join('/');
            if (baseUrl.includes('/channel/') || baseUrl.includes('/@')) {
                return baseUrl;
            }
            return window.location.href;
        }

        // Third try: Find any channel link on the page
        const channelLinks = document.querySelectorAll('a[href*="/channel/"], a[href*="/@"]');
        if (channelLinks.length > 0) {
            return channelLinks[0].href;
        }

        return null;
    }

    function isInputFocused() {
        const activeElement = document.activeElement;
        const tagName = activeElement.tagName.toLowerCase();
        return tagName === 'input' || tagName === 'textarea' || activeElement.isContentEditable;
    }

    // Navigation Functions
    function navigateToChannelVideos() {
        const channelUrl = getChannelInfo();
        if (channelUrl) {
            console.log("Channel URL detected:", channelUrl);

            // Construct the videos URL
            let videosUrl;

            // Handle different URL formats
            if (channelUrl.includes('/videos') || channelUrl.includes('/playlists')) {
                // Already has a section, replace it with /videos
                videosUrl = channelUrl.replace(/\/(videos|playlists|featured|about|community|shorts|streams).*$/, '/videos');
            } else {
                // Doesn't have a section yet, add /videos
                videosUrl = channelUrl + '/videos';
            }

            console.log("Opening videos URL:", videosUrl);
            window.open(videosUrl, '_blank');
            return true;
        } else {
            console.log("Could not detect channel URL");
        }
        return false;
    }

    function navigateToChannelPlaylists() {
        const channelUrl = getChannelInfo();
        if (channelUrl) {
            console.log("Channel URL detected:", channelUrl);

            // Construct the playlists URL
            let playlistsUrl;

            // Handle different URL formats
            if (channelUrl.includes('/videos') || channelUrl.includes('/playlists')) {
                // Already has a section, replace it with /playlists
                playlistsUrl = channelUrl.replace(/\/(videos|playlists|featured|about|community|shorts|streams).*$/, '/playlists');
            } else {
                // Doesn't have a section yet, add /playlists
                playlistsUrl = channelUrl + '/playlists';
            }

            console.log("Opening playlists URL:", playlistsUrl);
            window.open(playlistsUrl, '_blank');
            return true;
        } else {
            console.log("Could not detect channel URL");
        }
        return false;
    }

    function navigateToHistory() {
        window.open('https://www.youtube.com/feed/history', '_blank');
        return true;
    }

    function navigateToWatchLater() {
        window.open('https://www.youtube.com/playlist?list=WL', '_blank');
        return true;
    }

    function navigateToLikedVideos() {
        window.open('https://www.youtube.com/playlist?list=LL', '_blank');
        return true;
    }

    function navigateToSubscriptions() {
        window.open('https://youtube.com/feed/subscriptions', '_blank');
        return true;
    }

    function navigateToTrending() {
        window.open('https://youtube.com/feed/trending', '_blank');
        return true;
    }

    function focusSearchBar() {
        const searchBar = document.querySelector('input#search');
        if (searchBar) {
            searchBar.focus();
            return true; // Prevent default '/' behavior
        }
        return false;
    }

    // Video Control Functions
    function clickNextButton() {
        const nextButton = document.querySelector('.ytp-next-button');
        if (nextButton) {
            nextButton.click();
            return true;
        }
        return false;
    }

    function clickPrevButton() {
        const prevButton = document.querySelector('.ytp-prev-button');
        if (prevButton) {
            prevButton.click();
            return true;
        }
        return false;
    }

    function saveToPlaylist() {
        // Comprehensive approach to find the save button

        // 1. Try modern YouTube UI (desktop)
        let saveButton = document.querySelector('ytd-menu-renderer yt-button-shape button[aria-label*="Save"]');

        // 2. Try expanded action buttons
        if (!saveButton) {
            saveButton = document.querySelector('ytd-watch-metadata button[aria-label*="Save"]');
        }

        // 3. Try the "More actions" menu if it exists and need to open it first
        if (!saveButton) {
            const moreButton = document.querySelector('ytd-menu-renderer button[aria-label="More actions"], ytd-menu-renderer button[aria-label="More"]');
            if (moreButton) {
                moreButton.click();
                // Wait for menu to appear
                setTimeout(() => {
                    const saveOptionInMenu = document.querySelector('ytd-menu-service-item-renderer[aria-label*="Save"]');
                    if (saveOptionInMenu) {
                        saveOptionInMenu.click();
                    }
                }, 100);
                return true;
            }
        }

        // 4. Try old player UI
        if (!saveButton) {
            saveButton = document.querySelector('.ytp-save-button');
        }

        // 5. Fallback to text search
        if (!saveButton) {
            const allButtons = Array.from(document.querySelectorAll('button, ytd-button-renderer, yt-button-renderer'));
            saveButton = allButtons.find(btn => {
                const text = btn.textContent || '';
                return text.includes('Save');
            });
        }

        if (saveButton) {
            saveButton.click();
            console.log("Save button clicked");
            return true;
        }

        console.log("Save button not found");
        return false;
    }

    function saveToWatchLater() {
        // First, call saveToPlaylist to open the menu
        if (saveToPlaylist()) {
            // Wait for the save dialog to appear
            setTimeout(() => {
                // Try all possible selectors for watch later option
                const watchLaterSelectors = [
                    'ytd-playlist-add-to-option-renderer[aria-label="Watch later"]',
                    'tp-yt-paper-item:has(yt-formatted-string:contains("Watch later"))',
                    '.ytd-menu-service-item-renderer:contains("Watch later")',
                    'ytd-menu-service-item-renderer[aria-label*="Watch later"]',
                    'yt-formatted-string:contains("Watch later")',
                    'span:contains("Watch later")'
                ];

                // Try each selector
                for (const selector of watchLaterSelectors) {
                    try {
                        const watchLaterOption = document.querySelector(selector);
                        if (watchLaterOption) {
                            watchLaterOption.click();
                            console.log("Watch Later option clicked");

                            // Close the dialog if still open
                            setTimeout(() => {
                                const closeButtons = document.querySelectorAll('.ytd-add-to-playlist-renderer #close-button button, button[aria-label="Close"], tp-yt-paper-dialog button[aria-label="Cancel"]');
                                if (closeButtons.length) {
                                    closeButtons[0].click();
                                    console.log("Dialog closed");
                                }
                            }, 500);

                            return;
                        }
                    } catch (e) {
                        // Ignore selector errors
                    }
                }

                // Alternative: find by text content using Array.from and find
                const allElements = Array.from(document.querySelectorAll('ytd-playlist-add-to-option-renderer, yt-formatted-string, span, div'));
                const watchLaterOption = allElements.find(el => {
                    const text = el.textContent || '';
                    return text.trim() === 'Watch later';
                });

                if (watchLaterOption) {
                    watchLaterOption.click();
                    console.log("Watch Later option found and clicked via text search");
                } else {
                    console.log("Watch Later option not found");
                }
            }, 300);

            return true;
        }

        return false;
    }

    function copyVideoUrlWithTimestamp() {
        const video = document.querySelector('video');
        if (video) {
            const currentTime = Math.floor(video.currentTime);
            const url = new URL(window.location.href);

            // Remove any existing t parameter
            url.searchParams.delete('t');

            // Add the current timestamp
            if (currentTime > 0) {
                url.searchParams.set('t', currentTime + 's');
            }

            // Copy to clipboard
            navigator.clipboard.writeText(url.toString())
                .then(() => {
                    // Show a brief notification
                    const notification = document.createElement('div');
                    notification.textContent = 'URL copied to clipboard!';
                    notification.style.cssText = `
                        position: fixed;
                        bottom: 20px;
                        left: 50%;
                        transform: translateX(-50%);
                        background-color: rgba(0, 0, 0, 0.8);
                        color: white;
                        padding: 10px 15px;
                        border-radius: 4px;
                        z-index: 9999;
                    `;
                    document.body.appendChild(notification);

                    // Remove notification after 2 seconds
                    setTimeout(() => {
                        notification.remove();
                    }, 2000);
                })
                .catch(err => {
                    console.error('Could not copy URL: ', err);
                });
            return true;
        }
        return false;
    }

    function toggleSidebar() {
        // Find and click the guide button (hamburger menu) to toggle sidebar
        const guideButton = document.querySelector('button#guide-button, yt-icon-button#guide-button, ytd-topbar-menu-button-renderer button');
        if (guideButton) {
            guideButton.click();
            return true; // Prevent default Tab behavior
        }
        return false;
    }

    // Main event handler
    function handleKeyDown(event) {
        // Skip if an input or contenteditable is focused
        if (isInputFocused()) {
            return;
        }

        // Handle Tab key specially
        if (event.key === 'Tab' && !event.shiftKey && !event.ctrlKey && !event.altKey) {
            toggleSidebar();
            event.preventDefault();
            return;
        }

        // Get the key pressed
        const key = event.key;

        // Check if the key is in our bindings
        if (key in KEY_BINDINGS) {
            console.log(`Key '${key}' pressed, executing function:`, KEY_BINDINGS[key].name);
            // Execute the function
            const result = KEY_BINDINGS[key]();

            // If the function returns true, prevent default behavior
            if (result === true) {
                event.preventDefault();
            }
        }
    }

    // Add event listener for keydown
    document.addEventListener('keydown', handleKeyDown);

    // Log that the script is running
    console.log('YouTube Custom Hotkeys script loaded with bindings:', Object.keys(KEY_BINDINGS));
})();
