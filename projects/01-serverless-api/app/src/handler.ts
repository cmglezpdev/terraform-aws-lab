import { z } from "zod";
import { createLink } from "./application/create-link.ts";
import { InvalidTargetUrlError } from "./domain/errors.ts";
import { CodeCollisionError } from "./application/link-repository.ts";
import { DynamoDbLinkRepository } from "./infrastructure/dynamodb-link-repository.ts";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";

export interface CreateLinkResult {
  code: string;
  url: string;
}

const tableName = process.env.TABLE_NAME;
if (!tableName) throw new Error("Missing required environment variable TABLE_NAME");

const repository = new DynamoDbLinkRepository(new DynamoDBClient({}), tableName);

export const handler = async (event: unknown): Promise<CreateLinkResult> => {
  try {
    const link = await createLink(event, repository);
    console.log(JSON.stringify({ msg: "link created", ...link }));
    return link;
  } catch (error) {
    if (error instanceof InvalidTargetUrlError) {
      console.error(JSON.stringify({ msg: "invalid target url", reason: error.reason }));
    } else if (error instanceof z.ZodError) {
      console.error(JSON.stringify({ msg: "malformed payload", issues: error.issues }));
    } else if (error instanceof CodeCollisionError) {
      console.error(JSON.stringify({ msg: "code collision after retries", code: error.code }));
    }
    
    throw error;
  }
}