import { GetItemCommand, type DynamoDBClient } from "@aws-sdk/client-dynamodb";
import type { LinkFinder } from "../application/link-finder.ts";
import type { Link } from "../domain/link.ts";
import type { ShortCode } from "../domain/short-code.ts";
import type { TargetUrl } from "../domain/target-url.ts";


export class DynamoDbLinkFinder implements LinkFinder {
    private readonly client: DynamoDBClient;
    private readonly tableName: string;

    constructor(client: DynamoDBClient, tableName: string) {
        this.client = client;
        this.tableName = tableName;
    }

    async findByCode(code: ShortCode): Promise<Link | null> {
        const command = new GetItemCommand({
            TableName: this.tableName,
            Key: {
                code: { S: code },
            }
        })

        const result = await this.client.send(command);
        if(!result.Item) return null;
        return {
            code: result.Item.code?.S as ShortCode,
            url: result.Item.url?.S as TargetUrl,
        }
    }
}