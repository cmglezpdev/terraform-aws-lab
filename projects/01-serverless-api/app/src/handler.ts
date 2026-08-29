import { z } from "zod";
import { createLink } from "./application/create-link.ts";
import { InvalidTargetUrlError } from "./domain/errors.ts";
import { CodeCollisionError } from "./application/link-repository.ts";
import { DynamoDbLinkRepository } from "./infrastructure/dynamodb-link-repository.ts";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";

// API Gateway v1 event
interface HttpEvent {
  body?: string;
}

interface HttpResponse {
  statusCode: number;
  headers?: { "content-type": "application/json" };
  body?: string;
}

const tableName = process.env.TABLE_NAME;
if (!tableName) throw new Error("Missing required environment variable TABLE_NAME");

const repository = new DynamoDbLinkRepository(new DynamoDBClient({}), tableName);

const json = (statusCode: number, body: unknown): HttpResponse => ({
  statusCode,
  headers: { "content-type": "application/json" },
  body: JSON.stringify(body),
})

export const handler = async (event: HttpEvent): Promise<HttpResponse> => {
  let payload: unknown;
  try {
    payload = JSON.parse(event.body || "");
  } catch (error) {
    return json(400, { message: "body must be valid JSON" });
  }
  
  try {
    const link = await createLink(payload, repository);
    console.log(JSON.stringify({ msg: "link created", ...link }));
    return json(201, link);
  } catch (error) {
    if (error instanceof InvalidTargetUrlError) {
      console.error(JSON.stringify({ msg: "invalid target url", reason: error.reason }));
      return json(400, { message: "invalid target url", reason: error.reason });
    } else if (error instanceof z.ZodError) {
      console.error(JSON.stringify({ msg: "malformed payload", issues: error.issues }));
      json(400, { message: "malformed payload", issues: error.issues });
    } else if (error instanceof CodeCollisionError) {
      console.error(JSON.stringify({ msg: "code collision after retries", code: error.code }));
      json(400, { message: "code collision after retries", code: error.code });
    }
    
    // Todo lo demás es un 500: se relanza para que API Gateway lo cuente
    // como error y el REPORT de CloudWatch lo marque como fallo.
    throw error;
  }
}