import { z } from "zod";
import { createLink } from "./application/create-link.ts";
import { InvalidTargetUrlError } from "./domain/errors.ts";

export interface CreateLinkResult {
  code: string;
  url: string;
}

export const handler = async (event: unknown): Promise<CreateLinkResult> => {

  try {
    const link = createLink(event);
    console.log(JSON.stringify({ msg: "link created", ...link }));
    return link;
  } catch (error) {
    if (error instanceof InvalidTargetUrlError) {
      console.error(JSON.stringify({ msg: "invalid target url", reason: error.reason }));
    } else if (error instanceof z.ZodError) {
      console.error(JSON.stringify({ msg: "malformed payload", issues: error.issues }));
    }
    throw error;
  }
}