import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDbLinkFinder } from "../infrastructure/dynamodb-link-finder.ts";
import { getLink } from "../application/get-link.ts";

// API Gateway v1 event
interface HttpEvent {
	pathParameters?: { code: string };
}

interface HttpResponse {
  statusCode: number;
  headers?: { "content-type": "application/json" };
  body?: string;
}

const tableName = process.env.TABLE_NAME;
if (!tableName) throw new Error("Missing required environment variable TABLE_NAME");

const finder = new DynamoDbLinkFinder(new DynamoDBClient({}), tableName);

const json = (statusCode: number, body: unknown = {}, headers: Record<string, string> = {}): HttpResponse => ({
  statusCode,
  headers: { "content-type": "application/json", ...headers },
  body: JSON.stringify(body),
})

export const handler = async (event: HttpEvent): Promise<HttpResponse> => {
	const code = event.pathParameters?.code;
	const url = code ? await getLink(code, finder) : null;

	if(!url) {
		return json(404, { error: "unknown code" })
	}
	
	return json(302, undefined, { location: url });
}