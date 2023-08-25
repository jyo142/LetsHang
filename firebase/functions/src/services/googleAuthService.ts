import axios from "axios";

const clientId =
  "234546462541-v1lii1re9j69dm8ipve7ndf5b8jnr9fg.apps.googleusercontent.com";
const clientSecret = "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";

export const getRefreshToken = async (code: string) => {
  const redirectUri = "";
  const data = new URLSearchParams();
  data.append("code", code);
  data.append("client_id", clientId);
  data.append("client_secret", clientSecret);
  data.append("redirect_uri", redirectUri);
  data.append("grant_type", "authorization_code");
  const response = await axios.post(
    "https://oauth2.googleapis.com/token",
    data,
    {
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    },
  );
  return response?.data?.refresh_token;
};

export const getAccessTokenFromRefreshToken = async (refreshToken: string) => {
  const data = new URLSearchParams();
  data.append("client_id", clientId);
  data.append("client_secret", clientSecret);
  data.append("grant_type", "refresh_token");
  data.append("refresh_token", refreshToken);
  const response = await axios.post(
    "https://accounts.google.com/o/oauth2/token",
    data,
  );
  return response?.data?.access_token;
};
