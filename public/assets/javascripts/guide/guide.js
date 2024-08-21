function ready(fn) {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

function updateTime() {
  document.querySelector('.current-time').innerHTML = (new Date()).toLocaleTimeString('en-US').replace(/ [AP]M/, '') + "&nbsp;";
  setTimeout(updateTime, 1000);
}

function endlessLoadAndScroll() {
  if (!window.lineupInFlux) {
    scrollChannels();
  }
  setTimeout(endlessLoadAndScroll, 500);
}

function setCurrentTimeSlots(currentTimeSlots) {
  window.currentTimeSlots = currentTimeSlots;
  window.currentTimeSlots.forEach(updateTimeSlotDisplay);
}

function updateTimeSlotDisplay(timeSlotData, timeSlotIndex) {
  $(`.timeslots .timeslot:nth-child(${timeSlotIndex + 1})`).text(
    (new Date(timeSlotData.startTime)).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
  );
}

function reloadChannelData() {
  $.ajax({
    type: 'GET',
    url: '/schedule.json',
    success: setChannelData,
  });
  setTimeout(reloadChannelData, 10000);
}

function setChannelData(response) {
  window.currentLineup = response.channels;
  setCurrentTimeSlots(getCurrentTimeSlots());
}

function scrollChannels() {
  window.lineupInFlux = true;
  // load the next page
  loadNextChannels();

  // wait 2 seconds, then scroll the page and remove the viewed channels
  setTimeout(scrollOnePageThenRemoveViewedChannels, 2000);
}

function scrollOnePageThenRemoveViewedChannels() {
  // one page == 210px
  $('.lineup').animate({
      scrollTop: (210)
    },
    // the scroll animation should take 8 seconds
    8000,
    // when the scroll is done, remove the no longer visible, already seen divs
    // from the lineup
    removeViewedChannels
  );
}

// We are going through all the rows in reverse order, and summing the heights
// of them. Once we reach a number > 200, we just start deleting rows instead.
// The idea here is that we do not know how many rows make up a page, but we
// always want to remove everything but the currently visible page. Rows can
// be 70px tall, 140px tall, or 210px tall. There can be 1, 2, or 3 rows on a
// page. Counting the heights allows us to not care about how many rows make
// up the current page, and always remove all non-visible rows.
function removeViewedChannels() {
  var pageHeight = 0;
  for (const element of $('.lineup .channel, .announcement').toArray().reverse()) {
    if(pageHeight >= 200) {
      element.remove();
    } else {
      pageHeight += $(element).height();
    }
  }
  window.lineupInFlux = false;
}

function loadNextChannels() {
  if(window.currentLineup) {
    // pick the next three channels to display
    // startingIndex tells us where to start picking 3 channels from the lineup
    // data
    var startingIndex = 0

    // if we left off somewhere, pick back up from there (window.currentLineup
    // is assumed to be sorted by channel number)
    if(window.lastChannelLoaded) {
      // find the index of the first channel with a higher number than the last
      // one loaded, if there isn't a higher channel, or if there is no
      // information about which channel was loaded last, we'll start from the
      // top
			for (var i = 0; i < window.currentLineup.length; i++) {
				if(window.currentLineup[i].number > window.lastChannelLoaded){
          startingIndex = i;
					break;
				}
			}
    }
    var channelsToLoad = window.currentLineup.slice(startingIndex, startingIndex + 3);
    channelsToLoad.forEach(createAndAppendChannelFromChannelData);

    var leftoverChannelSlots = 3 - channelsToLoad.length;
    if(leftoverChannelSlots != 0) {
      $('.lineup').append(leftoverChannelSlot(leftoverChannelSlots));
		}
    
    window.lastChannelLoaded = channelsToLoad.slice(-1)[0].number;
  }
  // if we don't have any lineup data, display a placeholder announcement
  else {
    window.lastChannelLoaded = undefined;
    $('.lineup').append(placeholderChannelListings());
  }
}

function createAndAppendChannelFromChannelData(channelData) {
  $('.lineup').append(channelFromChannelData(channelData));
}

function leftoverChannelSlot(rowHeight) {
  var channel =  `
		<div class="announcement">
      All the TV shows and movies you love! Find it all here, on the Program Guide Channel.
		</div>
  `.trim();
  channel = $(channel);
  if(rowHeight == 2) {
    channel.addClass('double-height');
  }
  return channel;
}

function getCurrentTimeSlots() {
  var now = new Date()
  var firstStartTime = new Date(now)
  var firstEndTime = new Date(now)
  if(now.getMinutes() < 30) {
    firstStartTime.setMinutes(0);
    firstStartTime.setSeconds(0);
    firstEndTime.setMinutes(29);
    firstEndTime.setSeconds(59);
  }
  else {
    firstStartTime.setMinutes(30);
    firstStartTime.setSeconds(0);
    firstEndTime.setMinutes(59);
    firstEndTime.setSeconds(59);
  }
  firstStartTime.setMilliseconds(0);
  firstEndTime.setMilliseconds(0);
  var secondStartTime = new Date(firstStartTime);
  secondStartTime.setMinutes(firstStartTime.getMinutes() + 30)
  secondStartTime.setMilliseconds(0);
  var secondEndTime = new Date(firstEndTime);
  secondEndTime.setMinutes(firstEndTime.getMinutes() + 30)
  secondEndTime.setMilliseconds(0);
  var thirdStartTime = new Date(firstStartTime);
  thirdStartTime.setMinutes(firstStartTime.getMinutes() + 60)
  thirdStartTime.setMilliseconds(0);
  var thirdEndTime = new Date(firstEndTime);
  thirdEndTime.setMinutes(firstEndTime.getMinutes() + 60)
  thirdEndTime.setMilliseconds(0);

  return [
    {
      startTime: firstStartTime,
      endTime: firstEndTime
    },
    {
      startTime: secondStartTime,
      endTime: secondEndTime
    },
    {
      startTime: thirdStartTime,
      endTime: thirdEndTime
    }
  ]
}

// Goodness what a mess. Once it's all working I'd like to change this to not
// operate on times but instead on CURDAY.DAT style timeslot numbers. (1 == 3am, 2 == 3:30am, etc.)
function channelFromChannelData(channelData) {
  var channel =  `
		<div class="channel">
			<div class="station-identifier">
				<div class="number">
					${channelData.number}
				</div>
				<div class="name">
					${channelData.short_name}
				</div>
			</div>
		</div>
  `.trim();
	var channelLineup = `
    <div class="channel-lineup">
		</div>
  `.trim()
  channel = $(channel);
  channelLineup = $(channelLineup);

  var currentStartTimes = collectAttributeFromObjectList(window.currentTimeSlots, 'startTime');
  var currentStartTimeISOStrings = currentStartTimes.map(
    function (e) {
      return e.toISOString().split('.')[0];
    }
  );

  var currentEndTimes = collectAttributeFromObjectList(window.currentTimeSlots, 'endTime');
  var currentEndTimeISOStrings = currentEndTimes.map(
    function (e) {
      return e.toISOString().split('.')[0];
    }
  );

  for (var i = 0; i < channelData.lineup.length; i++) {
    var contentData = channelData.lineup[i];

    content_start_time = new Date(contentData.start_time);
    content_end_time = new Date(new Date(contentData.end_time) - 1000);

    if (
          contentData.all_day ||
          currentStartTimeISOStrings.includes(content_start_time.toISOString().split('.')[0]) ||
          currentEndTimeISOStrings.includes(content_end_time.toISOString().split('.')[0]) ||
          (content_start_time < currentStartTimes[0] && content_end_time > currentEndTimes[2])
        ) {
      var lineupItem = `<div class="channel-lineup-item">
        <div class="before-arrow"><br/></div>
        <div class="before-double-arrow"><br/></div>
        <span class="title">${contentData.title}</span>
        <div class="after-arrow"><br/></div>
        <div class="after-double-arrow"><br/></div>
      </div>`.trim();
      lineupItem = $(lineupItem);

      // All day events take up the whole channel row
      if(contentData.all_day) {
        lineupItem.addClass('all-day');
      }

      // Entry length cases:
      //
      // single cell length:
      // - ends on the first time slot
      // - starts and ends on the second time slot
      // - starts on the third time slot
      //
      // double cell length:
      // - none of the above AND:
      //   - ends on the second end time slot
      //   - starts on the second start time slot
      //
      // triple cell length:
      // - none of the above AND:
      //   - starts on the first time slot, ends on the third end time slot
      //   - starts on the first time slot, ends sometime after the third end
      //   time slot
      //   - started in the past, ends on or after the third end time slot
      
      if (
        (content_end_time.getTime() == currentEndTimes[0].getTime()) ||
        (content_start_time.getTime() == currentStartTimes[1].getTime() && content_end_time.getTime() == currentEndTimes[1].getTime()) ||
        (content_start_time.getTime() == currentStartTimes[2].getTime())
      ) {
        lineupItem.addClass('single');
      } else if (
        (content_end_time.getTime() == currentEndTimes[1].getTime()) ||
        (content_start_time.getTime() == currentStartTimes[1].getTime() && content_end_time.getTime() >= currentEndTimes[2].getTime())
      ) {
        lineupItem.addClass('double');
      } else {
        lineupItem.addClass('triple');
      }


      // Display the single or double left arrow if needed
      if(contentData.minutes_elapsed >= 60) {
        lineupItem.addClass('started-a-long-while-ago');
      } else if(contentData.minutes_elapsed >= 30) {
        lineupItem.addClass('started-a-little-while-ago');
      }

      // Display the single or double right arrow if needed
      if(contentData.minutes_remaining > 60) {
        lineupItem.addClass('a-lot-left');
      } else if(contentData.minutes_remaining >= 30) {
        lineupItem.addClass('a-little-left');
      }

      // Mark sports and movies in specific colors
      if(contentData.category && contentData.category == 'sporting event') {
        lineupItem.addClass('sports');
      }
      if(contentData.category && contentData.category == 'movie') {
        lineupItem.addClass('movie');
      }
      channelLineup.append(lineupItem);
    }
  }
  
  channel.append(channelLineup);
  return channel
}

function collectAttributeFromObjectList(list, attribute) {
  var attributeList = [];
  for (const object of list) {
    attributeList.push(object[attribute]);
  }
  return attributeList;
}

function placeholderChannelListings() {
  return `
    <div class="channel announcement triple-height">
      <div class="channel-lineup-item">
          Welcome to the guide channel. There's something for everyone!
      </div>
    </div>
  `.trim();
}

ready(updateTime);
ready(reloadChannelData);
ready(endlessLoadAndScroll);
