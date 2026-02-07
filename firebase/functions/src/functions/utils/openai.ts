import { defineString } from "firebase-functions/params";
import { OpenAI } from "openai";

// https://github.com/firebase/firebase-functions/issues/1567#issue-2303336877
// 本当はdefineSecretを使いたい
defineString("OPENAI_API_KEY");
export function openai(): OpenAI {
  return new OpenAI();
}
