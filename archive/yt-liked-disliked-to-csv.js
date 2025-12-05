(() => {
  // Header names for the CSV columns
  let csv = "action,video_title,video_link,author_name,author_link\n";

  // Finding all videos in the playlist
  const videos = document.querySelectorAll(".xDtZAf");

  // For each video found, extract some information about it (action (liked or disliked), title, URL, author, author URL) and add it to the CSV
  for (const video of videos) {
    try {
      // Finding the HTML elements
      const actionElem = video.querySelector(".QTGV3c");
      const titleElem = actionElem.querySelector("a");

      // Extracting the text and links from the elements
      let action = actionElem.firstChild.textContent.trim(" ").toLowerCase();
      let videoTitle = titleElem.textContent;
      let videoID = new URL(titleElem.href).searchParams.get("v");

      // Some of the links will be deleted, so we check that here
      let authorName, authorID;
      try {
        const authorElem = video.querySelector(".SiEggd a");
        authorName = authorElem.textContent;
        authorID = new URL(authorElem.href).pathname.split("/").pop();
      } catch {
        videoTitle = null;
      }

      // Adding everything to the CSV
      csv +=
        [
          action,
          videoTitle ? `"${videoTitle.replaceAll('"', '""')}"` : "[deleted]",
          `https://youtube.com/watch?v=${videoID}`,
          authorName ? `"${authorName.replaceAll('"', '""')}"` : "[deleted]",
          authorID ? `https://youtube.com/channel/${authorID}` : "[deleted]",
        ].join(",") + "\n";
    } catch (err) {
      console.error("failed to extract info for ", video, err);
    }
  }

  // Once we're finished, we'll download the generated CSV as a file
  const a = document.createElement("a");
  a.href = "data:text/csv;charset=UTF-8," + encodeURIComponent(csv);
  a.download = "likes.csv";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
})();
