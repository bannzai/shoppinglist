type AuthPolicy = (auth: any, data: any) => boolean | Promise<boolean>;

export function appAuthPolicy(fn: string): AuthPolicy {
  if (process.env.ENV === "local") {
    return () => true;
  }
  // 他のonFlowからrunFlow経由で呼び出す場合は、FUNCTION_NAMEが一致しないため、認証をスキップする
  if (process.env.FUNCTION_NAME !== fn) {
    return () => true;
  }
  return (auth) => {
    if (!auth) {
      throw new Error("Unauthenticated");
    }
    if (auth.token?.exp * 1000 < Date.now()) {
      throw new Error("User token is expired");
    }

    if (process.env.FUNCTIONS_EMULATOR === "true") {
      console.log("[DEBUG] User ID: ", auth.uid);
    }
    return true;
  };
}
