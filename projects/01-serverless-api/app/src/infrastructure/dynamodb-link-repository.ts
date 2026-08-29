import { ConditionalCheckFailedException, PutItemCommand, type DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { CodeCollisionError, type LinkRepository } from "../application/link-repository.ts";
import type { Link } from "../domain/link.ts";


export class DynamoDbLinkRepository implements LinkRepository {
    private readonly client: DynamoDBClient;
    private readonly tableName: string;
    
    constructor(client: DynamoDBClient, tableName: string) {
        this.client = client;
        this.tableName = tableName;
    }

    async save(link: Link): Promise<void> {
        const command = new PutItemCommand({
            TableName: this.tableName,
            Item: {
                code: { S: link.code },
                url: { S: link.url },
                created_at: { S: new Date().toISOString() },
            },
            ConditionExpression: "attribute_not_exists(code)",
        });

        try {
            await this.client.send(command);
        } catch (error) {
            if (error instanceof ConditionalCheckFailedException) {
                throw new CodeCollisionError(link.code);
            }
            throw error;
        }
    }
}