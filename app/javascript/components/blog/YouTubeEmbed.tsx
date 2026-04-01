import ReactPlayer from "react-player";

type YouTubeEmbedProps = {
  url: string;
};

export default function YouTubeEmbed({ url }: YouTubeEmbedProps) {
  return (
    <div className="blog-video-embed not-prose">
      <div className="blog-video-embed__frame">
        <ReactPlayer
          controls
          height="100%"
          playsInline
          src={url}
          width="100%"
        />
      </div>
    </div>
  );
}
