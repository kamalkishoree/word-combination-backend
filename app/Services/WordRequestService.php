<?php
namespace App\Services;

use GuzzleHttp\Client;
use Symfony\Component\DomCrawler\Crawler;

class WordRequestService
{

    public function wordRequest($Word)
    {
        $client = new Client();
        $response = $client->request('GET', 'https://wordcollectanswers.com/en/?letters=' . $Word);
        $statusCode = $response->getStatusCode();
        $content = $response->getBody()->getContents();
        $crawler = new Crawler($content);
        $divContent = $crawler->filter('.words')->html();
        $text_array = explode("<br>", preg_replace('/\d+\.\s*/', '', $divContent));
        $result = array_map(function ($item) {
            return strip_tags($item);
        }, $text_array);
        
        return $result;
    }
}