function ready(fn) {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

function updatePreviewSection() {
  // Initial state for page load

  // We should attempt to load a preview
  window.previewComplete = true;
  // No new preview data has been loaded
  window.newPreviewDataLoaded = false;
  // No data is currently being loaded.
  window.previewDataLoading = false;

  // Set an interval to check if we need to prepare and show a preview, and do
  // so if needed. The previewComplete semephore prevents this from running if
  // a preview is still in progress. It will be set to true on page load (a
  // few lines above), and when a media element completes playback.
  setInterval(prepareAndShowPreviewIfNeeded, 500);
}

function prepareAndShowPreviewIfNeeded() {
  // only do something if there is no preview in progress
  if (window.previewComplete) {

    // if we are waiting on the preview data to be loaded
    if (window.previewDataLoading) {
      return;
    } else {
      // we know no data is in the process of being loaded, so go ahead and get that started
      getPreviewData();
    }

    // only proceed if the preview data is ready for us
    if (window.newPreviewDataLoaded) {
      // start loading the new preview!

      // make sure nothing interrupts us.
      window.previewComplete = false;

      // If there is an audio attribute, load the track into the audio
      // element. If there is not an audio attribute, see if we should load a
      // video.
      if(window.previewData.audio) {
        setMediaElementTrack(previewAudioElement(), window.previewData.audio);
      } else if(window.previewData.video) {
        setMediaElementTrack(previewVideoElement(), window.previewData.video);
      }
      // If there are messages, show them in the container. We do this by
      // setting the initial message, then setting up an interval to fade it
      // out, change the message, then fade it in every 10 seconds.
      if(window.previewData.messages) {
        setPreviewMessage(newMessage());

        // Every interval, refresh the message.
        window.messageReplacementInterval = setInterval(refreshMessage, 10000);
      }

      // Now that we are done setting up the preview, go ahead and bring it
      // into view. Keep in mind, though, that many of these actions will
      // happen asynchronously. We might be fading in before everything is
      // ready, but also many of those actions are very quick.
      previewContainer().fadeIn();
    }
  }
}

function refreshMessage() {
  previewMessagesContainerElement().fadeOut(setPreviewMessageAndFadeIn);
}

function setPreviewMessageAndFadeIn() {
  setPreviewMessage(newMessage());
  previewMessagesContainerElement().fadeIn();
}


// Utility function that ensures a media element loads a particular track.
function setMediaElementTrack(mediaElement, trackSourceUrl) {
  // Empty the media element so we know there are no other track sources.
  mediaElement.empty();
  // Add the new track source
  mediaElement.append($(`<source src='${trackSourceUrl}' onerror="fadeOutPreview()"/>`));
  // Call load so the element re-evaluates what it should play and
  // starts playing it.
  mediaElement[0].load();
}

// Utility function that sets the current text of the preview message.
function setPreviewMessage(message) {
  previewMessagesContainerElement().empty();
  previewMessagesContainerElement().text(message);
}

// If it exists, return it, if it doesn't, make it, then return it.
function previewAudioElement() {
  var audioElement = previewContainer().children('audio')[0];
  if(audioElement) {
    return $(audioElement);
  } else {
    audioElement = $('<audio></audio>');
    setMediaElementEvents(audioElement);
    previewContainer().append(audioElement);
    return audioElement;
  }
}

// If it exists, return it, if it doesn't, make it, then return it.
function previewVideoElement() {
  var videoElement = previewContainer().children('video')[0];
  if(videoElement) {
    return $(videoElement);
  } else {
    videoElement = $('<video></video>');
    setMediaElementEvents(videoElement);
    previewContainer().append(videoElement);
    return videoElement;
  }
}

function setMediaElementEvents(mediaElement) {
  // When the media finishes, end the preview
  mediaElement.on('ended', waitHalfASecondThenFadeOutPreview);

  // We tried listening to 'canplaythrough', but it did not always fire,
  // even after a long time. Maybe the browser intentionally doesn't
  // fetch the whole thing?
  mediaElement.on('canplay', playMediaElement);
}

function playMediaElement() {
  this.play();
}

// If it exists, return it, if it doesn't, make it, then return it.
function previewMessagesContainerElement() {
  var messagesContainer = previewContainer().children('.previewMessages')[0];
  if(messagesContainer) {
    return $(messagesContainer);
  } else {
    messagesContainer = $('<div class="previewMessages"></div>');
    previewContainer().append(messagesContainer);
    return messagesContainer;
  }
}

// Find a message to display that is different from the one currently
// displayed.
function newMessage() {
  var randomMessageIndex = Math.floor(Math.random() * window.previewData.messages.length);
  var messageToDisplay = window.previewData.messages[randomMessageIndex];
  while (messageToDisplay == previewMessagesContainerElement().text()) {
    randomMessageIndex = Math.floor(Math.random() * window.previewData.messages.length);
    messageToDisplay = window.previewData.messages[randomMessageIndex];
  }
  return messageToDisplay;
}

function waitHalfASecondThenFadeOutPreview() {
  setTimeout(fadeOutPreview, 500);
}

function fadeOutPreview() {
  previewContainer().fadeOut(endPreview);
}

// Fade out. When the fade out is complete,
// it will set the previewComplete to true, so the cycle can begin anew.
function endPreview() {
  if(window.messageReplacementInterval) {
    clearInterval(window.messageReplacementInterval);
    window.messageReplacementInterval = null;
  }
  window.previewComplete = true;
  for( const mediaElement of previewContainer().children('audio, video')) {
    mediaElement.pause();
    $(mediaElement).children('source').remove();
  }
  setPreviewMessage('');
}

// If it exists, return it, if it doesn't, make it, then return it.
function previewContainer() {
  var currentPreview = $('.previews .currentPreview')[0];
  if(currentPreview) {
    return $(currentPreview);
  } else {
    currentPreview = `
    <div class='currentPreview'>
    </div>
    `;
    currentPreview = $(currentPreview);
    $('.previews').append(currentPreview);
    return currentPreview;
  }
}

function getPreviewData() {
  $.ajax({
    type: 'GET',
    url: '/preview',
    success: setPreviewData
  });
}

function setPreviewData(response) {
  window.previewData = response;
  window.newPreviewDataLoaded = true;
  window.previewDataLoading = false;
}

//ready(updatePreviewSection);
