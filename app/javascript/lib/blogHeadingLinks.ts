import type { ToastEventDetail, ToastType } from "@/types/toast";

const BLOG_HEADING_LINK_SELECTOR = ".blog-prose .heading-anchor";

let blogHeadingLinksInitialized = false;

function dispatchToast(message: string, type: ToastType) {
  const detail: ToastEventDetail = { message, type };
  window.dispatchEvent(new CustomEvent("toast:add", { detail }));
}

async function copyText(value: string) {
  if (typeof navigator !== "undefined" && navigator.clipboard?.writeText) {
    await navigator.clipboard.writeText(value);
    return;
  }

  const textarea = document.createElement("textarea");
  textarea.value = value;
  textarea.setAttribute("readonly", "");
  textarea.style.position = "absolute";
  textarea.style.left = "-9999px";

  document.body.appendChild(textarea);
  textarea.select();

  const copied = document.execCommand("copy");
  textarea.remove();

  if (!copied) {
    throw new Error("Clipboard copy failed");
  }
}

async function handleHeadingLinkClick(event: MouseEvent) {
  const target = event.target;
  if (!(target instanceof Element)) {
    return;
  }

  const link = target.closest(BLOG_HEADING_LINK_SELECTOR);
  if (!(link instanceof HTMLAnchorElement)) {
    return;
  }

  event.preventDefault();

  const href = link.getAttribute("href");
  if (!href) {
    return;
  }

  const url = new URL(href, window.location.href);

  try {
    await copyText(url.toString());
    window.history.replaceState(window.history.state, "", `${url.pathname}${url.search}${url.hash}`);
    dispatchToast("Section link copied.", "success");
  } catch {
    dispatchToast("Could not copy the section link.", "error");
  }
}

export function initializeBlogHeadingLinks() {
  if (blogHeadingLinksInitialized || typeof document === "undefined") {
    return;
  }

  document.addEventListener("click", event => {
    void handleHeadingLinkClick(event);
  });

  blogHeadingLinksInitialized = true;
}

initializeBlogHeadingLinks();
