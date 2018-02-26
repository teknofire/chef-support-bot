#!/bin/bash

API_KEY=abcdef
SERVER=localhost:5000

echo -n "Registering Will"
curl -s -X POST http://$SERVER/people/register -H "content-type: application/x-www-form-urlencoded" -d "text=&token=$API_KEY&channel_name=foo&user_id=abcdefg&user_name=will&response_url=http://google.com" | jq .text
exit
echo -n "Marking Will as unavailable: "
curl -s -X POST http://$SERVER/people/unavailable -H "content-type: application/x-www-form-urlencoded" -d "text=&token=$API_KEY&channel_name=foo&user_name=will&response_url=http://google.com" | jq .text
echo -n "Marking Glass as available: "
curl -s -X POST http://$SERVER/people/available -H "content-type: application/x-www-form-urlencoded" -d "text=&token=$API_KEY&channel_name=foo&user_name=glass&response_url=http://google.com" | jq .text
echo -n "Requesting ticket assignment for 12345: "
curl -s -X POST http://$SERVER/ticket -H "content-type: application/x-www-form-urlencoded" -d "text=12345&token=$API_KEY&channel_name=foo&user_name=glass&response_url=http://google.com" | jq .text
echo -n "Requesting ticket assignment for 54321 chef-client: "
curl -s -X POST http://$SERVER/ticket -H "content-type: application/x-www-form-urlencoded" -d "text=12345 chef-client&token=$API_KEY&channel_name=foo&user_name=glass&response_url=http://google.com" | jq .text
curl -s -X POST http://$SERVER/ticket -H "content-type: application/x-www-form-urlencoded" -d "text=12345 chef-client&token=$API_KEY&channel_name=foo&user_name=glass&response_url=http://google.com" | jq .attachments
echo -n "Requesting ticket assignment for 54321 chef: "
curl -s -X POST http://$SERVER/ticket -H "content-type: application/x-www-form-urlencoded" -d "text=12345 chef&token=$API_KEY&channel_name=foo&user_name=glass&response_url=http://google.com" | jq .attachments
echo -n "Requesting ticket assignment for 54321 chef-cli: "
curl -s -X POST http://$SERVER/ticket -H "content-type: application/x-www-form-urlencoded" -d "text=12345 chef-cli&token=$API_KEY&channel_name=foo&user_name=glass&response_url=http://google.com" | jq .attachments
echo -n "Show status: "
curl -s -X POST http://$SERVER/people -H "content-type: application/x-www-form-urlencoded" -d "text=&token=$API_KEY&channel_name=foo&user_name=glass&response_url=http://google.com" | jq .attachments
curl -s -X POST http://$SERVER/actions -H "content-type: application/x-www-form-urlencoded" -d "payload={\"type\":\"interactive_message\",\"actions\":[{\"name\":\"product\",\"type\":\"button\",\"value\":\"chef-ha\"}],\"callback_id\":\"assign_ticket:12345\",\"team\":{\"id\":\"T8XEWREKD\",\"domain\":\"teknofire\"},\"channel\":{\"id\":\"C8XEWRKMZ\",\"name\":\"general\"},\"user\":{\"id\":\"U8WU40EBA\",\"name\":\"will\"},\"action_ts\":\"1517875962.311014\",\"message_ts\":\"1517875560.000217\",\"attachment_id\":\"1\",\"token\":\"JsZp9U0vpHXv7J1jAcQ4tlyv\",\"is_app_unfurl\":false,\"response_url\":\"https:\\/\\/hooks.slack.com\\/actions\\/T8XEWREKD\\/309687824912\\/9svEFXKgS5soxm7KHSe33kQA\",\"trigger_id\":\"310458329141.303506864659.c52b7be173f44ee352227324298b78a7\"}" | jq .
