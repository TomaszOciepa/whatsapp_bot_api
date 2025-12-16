document.addEventListener("DOMContentLoaded", () => {
  const messages = document.querySelectorAll(".chat-bubble");
  const maxLoops = 1;
  const messageDelay = 200;
  const loopPause = 2000;

  let loopCount = 0;

  function resetChat() {
    messages.forEach((msg) => {
      msg.style.opacity = "0";
      msg.style.transform = "translateY(10px)";
    });
  }

  function playChat() {
    messages.forEach((msg, index) => {
      setTimeout(() => {
        msg.style.opacity = "1";
        msg.style.transform = "translateY(0)";
      }, index * messageDelay);
    });

    const totalDuration = messages.length * messageDelay;

    setTimeout(() => {
      loopCount++;

      if (loopCount < maxLoops) {
        resetChat();
        setTimeout(playChat, 600); // mała pauza przed kolejną pętlą
      }
    }, totalDuration + loopPause);
  }

  // start
  resetChat();
  playChat();
});
