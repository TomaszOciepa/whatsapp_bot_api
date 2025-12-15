document.addEventListener("DOMContentLoaded", () => {
  const messages = document.querySelectorAll(".chat-bubble");

  messages.forEach((msg, i) => {
    setTimeout(() => {
      msg.style.opacity = "1";
      msg.style.transform = "translateY(0)";
    }, i * 900);
  });
});
