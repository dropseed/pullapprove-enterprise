export const contextForStatus = (status) => {
  let avatarUrlFormat = "https://github.com/{username}.png";

  if (
    "github_api_base_url" in status.meta &&
    status.meta.github_api_base_url !== "https://api.github.com"
  ) {
    avatarUrlFormat =
      status.meta.github_api_base_url.replace("/api/v3", "") +
      "/{username}.png";
  }

  return { avatarUrlFormat };
};
