package com.example.placement.controller;

import com.example.placement.dto.student.PlatformLinkRequest;
import com.example.placement.dto.student.ProjectRequest;
import com.example.placement.dto.student.StudentProfileRequest;
import com.example.placement.entity.Platform;
import com.example.placement.entity.Project;
import com.example.placement.entity.Skill;
import com.example.placement.entity.main.StudentProfile;
import com.example.placement.service.StudentProfileService;
import org.springframework.web.bind.annotation.*;

@RestController     //spring will handle http requests here
@RequestMapping("/api/students")
public class StudentProfileController {
    private final StudentProfileService service;


    public StudentProfileController(StudentProfileService service) {
        this.service = service;
    }

    //http post request
    @PostMapping("/{userId}/profile")
    public StudentProfile createProfile(
            //binds a segment of url path to a method parameter
            @PathVariable Long userId,
            //binds the http reuest body to a java object
            @RequestBody StudentProfileRequest request
    ){
        StudentProfile profile = new StudentProfile();
        profile.setName(request.getName());
        profile.setDomainRole(request.getDomainRole());
        profile.setPhoneNumber(request.getPhoneNumber());
        profile.setPhotoUrl(request.getPhotoUrl());
        profile.setBio(request.getBio());
        profile.setAddressLine(request.getAddressLine());
        profile.setCity(request.getCity());
        profile.setState(request.getState());
        profile.setDob(request.getDob());

        Skill skills = null;
        if (request.getSkills() != null) {
            skills = new Skill();
            skills.setLanguages(request.getSkills().getLanguages());
            skills.setFrameworks(request.getSkills().getFrameworks());
            skills.setTools(request.getSkills().getTools());
            skills.setPlatforms(request.getSkills().getPlatforms());
        }

        //call service to save profile
        StudentProfile savedProfile =  service.createProfile(profile, skills, userId);

        return savedProfile;
    }

    //add proj
    @PostMapping("/{studentId}/projects")
    public Project addProject(
            @PathVariable Long studentId,
            @RequestBody ProjectRequest request
    ){
        Project project = new Project();
        project.setTitle(request.getTitle());
        project.setDescription(request.getDescription());
        project.setLink(request.getLink());

        return service.addProject(project, studentId);
    }

    @PostMapping("/{studentId}/platforms")
    public Platform addPlatform(
            @PathVariable Long studentId,
            @RequestBody PlatformLinkRequest request
    ) {
        Platform platform = new Platform();
        platform.setType(request.getType());
        platform.setUrl(request.getUrl());

        return service.addLink(platform, studentId);
    }

    /** Path id is {@link com.example.placement.entity.main.User} id (same as POST create profile). */
    @GetMapping("/{userId}/profile")
    public StudentProfile getProfile(@PathVariable Long userId) {
        return service.getStudentProfile(userId);
    }
}
