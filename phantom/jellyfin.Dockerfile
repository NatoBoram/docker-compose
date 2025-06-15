FROM jellyfin/jellyfin

RUN curl --fail --location --output /usr/local/bin/yt-dlp --show-error --silent https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux
RUN chmod +x /usr/local/bin/yt-dlp
RUN yt-dlp -U
