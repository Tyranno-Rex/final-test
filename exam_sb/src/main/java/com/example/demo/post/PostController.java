package com.example.demo.post;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class PostController {
    private final PostRepository postRepository;

    @PostMapping("/posts")
    public String createPost(@RequestBody PostDTO postDTO) {
        Post post = new Post();
        post.setTitle(postDTO.getTitle());
        post.setContent(postDTO.getContent());
        System.out.println("Post created");
        System.out.println(postDTO.getTitle());
        System.out.println(postDTO.getContent());
        postRepository.save(post);
        return "Post created";
    }

    @GetMapping("/posts")
    public Page<Post> getPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "9") int size) {

        Pageable pageable = PageRequest.of(page, size);
        return postRepository.findAll(pageable);
    }

    @PutMapping("/posts")
    public String updatePost(@RequestBody PostPutDTO postPutDTO){
        Post post = postRepository.findById(Long.parseLong(postPutDTO.getId())).orElse(null);
        assert post != null;
        post.setTitle(postPutDTO.getTitle());
        post.setContent(postPutDTO.getContent());
        postRepository.save(post);
        return "Post updated";
    }

    @DeleteMapping("/posts")
    public String deletePost(@RequestParam Long id) {
        postRepository.deleteById(id);
        return "Post deleted";
    }

    @GetMapping("/getPost")
    public Map<String, String> getPost(@RequestParam Long id) {
        Post post = postRepository.findById(id).orElse(null);
        assert post != null;
        return Map.of("title", post.getTitle(), "content", post.getContent());
    }

    private final RestTemplate restTemplate = new RestTemplate();

    @GetMapping("/today-weather")
    public String getTodayWeather() {
        String url = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=%2B8aTLhoKPaPMuDqlPKRrcEEonjDzS0WkW4EX4Yw3sCC7AGKM%2FmTHQRYjTfhLEamD%2FtG40moxUbI3jPFLVQ%2FwnA%3D%3D&pageNo=1&numOfRows=1000&dataType=JSON&base_date=20240802&base_time=1200&nx=61&ny=128";
        ResponseEntity<String> result = restTemplate.getForEntity(url, String.class);
        System.out.println(result.getBody());
        return result.getBody();
    }
}
