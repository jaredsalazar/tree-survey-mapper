import { mkdir, copyFile, writeFile } from "node:fs/promises";

const siteGroups = process.env.SITE_GROUPS_JSON ? JSON.parse(process.env.SITE_GROUPS_JSON) : [];
const config = {
  googleMapsApiKey: process.env.GOOGLE_MAPS_API_KEY || "",
  supabaseUrl: process.env.SUPABASE_URL || "",
  supabasePublishableKey: process.env.SUPABASE_PUBLISHABLE_KEY || "",
  defaultSurvey: process.env.DEFAULT_SURVEY || "demo-survey",
  siteGroups
};
await mkdir("dist", { recursive: true });
await copyFile("index.html", "dist/index.html");
await writeFile("dist/config.js", `window.TREE_SURVEY_CONFIG = ${JSON.stringify(config)};\n`, "utf8");
