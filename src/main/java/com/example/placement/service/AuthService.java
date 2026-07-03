package com.example.placement.service;

import com.example.placement.dto.auth.AuthRequest;
import com.example.placement.dto.auth.AuthResponse;
import com.example.placement.dto.auth.RegisterRequest;
import com.example.placement.common.enums.RoleType;
import com.example.placement.entity.main.User;
import com.example.placement.repository.UserRepo;
import com.example.placement.security.JwtUtil;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service        //service bean
public class AuthService {
    private final UserRepo userRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    /** Login and registration: only {@code local@student.com}, {@code local@staff.com}, or {@code local@system.com}. */
    private static final Pattern STRICT_ROLE_EMAIL_PATTERN =
            Pattern.compile("^[a-z0-9._%+-]+@(student|staff|system)\\.com$");

    //constructor based dependency injection
    public AuthService(UserRepo userRepo, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepo = userRepo;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    // Unified auth flow: registers if user does not exist, otherwise authenticates existing user.
    public AuthResponse authenticateOrRegister(AuthRequest request) {
        if (request == null
                || request.getEmail() == null || request.getEmail().trim().isEmpty()
                || request.getPassword() == null || request.getPassword().trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Missing required fields");
        }
        if (request.getRole() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Role is required");
        }
        String email = request.getEmail().trim().toLowerCase();
        requireStrictRoleEmail(email, request.getRole());

        User existing = userRepo.findByEmail(email).orElse(null);

        if (existing == null) {
            User user = new User();
            user.setEmail(email);
            user.setPassword(passwordEncoder.encode(request.getPassword()));
            user.setRole(request.getRole());
            User saved = userRepo.save(user);
            return new AuthResponse(jwtUtil.generateToken(saved), saved.getEmail(), extractRoleNames(saved));
        }

        if (existing.getRole() == null || existing.getRole() != request.getRole()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }
        String stored = existing.getPassword();
        if (stored == null || !isBcryptEncoded(stored) || !passwordEncoder.matches(request.getPassword(), stored)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }
        return new AuthResponse(jwtUtil.generateToken(existing), existing.getEmail(), extractRoleNames(existing));
    }

    // Backward-compatible registration method that maps to unified auth flow.
    public AuthResponse registerStudent(RegisterRequest request) {
        if (request == null
                || request.getEmail() == null || request.getEmail().trim().isEmpty()
                || request.getPassword() == null || request.getPassword().trim().isEmpty()
                || request.getPasswordBased() == null
                || request.getRole() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Missing required fields");
        }
        if (request.getRole() != RoleType.STUDENT) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid role for this endpoint");
        }
        AuthRequest authRequest = new AuthRequest();
        authRequest.setEmail(request.getEmail());
        authRequest.setPassword(request.getPassword());
        authRequest.setRole(RoleType.STUDENT);
        return authenticateOrRegister(authRequest);
    }

    // Login only: strict name@student.com | name@staff.com | name@system.com; no auto-registration.
    public AuthResponse login(AuthRequest request) {
        if (request == null
                || request.getRole() == null
                || request.getEmail() == null || request.getEmail().trim().isEmpty()
                || request.getPassword() == null || request.getPassword().trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Missing required fields");
        }
        String email = request.getEmail().trim().toLowerCase();
        requireStrictRoleEmail(email, request.getRole());

        User existing = userRepo.findByEmail(email).orElse(null);
        if (existing == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }
        if (existing.getRole() == null || existing.getRole() != request.getRole()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }
        String stored = existing.getPassword();
        if (stored == null || !isBcryptEncoded(stored) || !passwordEncoder.matches(request.getPassword(), stored)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }
        return new AuthResponse(jwtUtil.generateToken(existing), existing.getEmail(), extractRoleNames(existing));
    }

    private static void requireStrictRoleEmail(String email, RoleType roleType) {
        Matcher matcher = STRICT_ROLE_EMAIL_PATTERN.matcher(email);
        if (!matcher.matches()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Use strictly: <name>@student.com for Student, <name>@staff.com for Staff, <name>@system.com for System"
            );
        }
        String roleSegment = matcher.group(1);
        String expected = roleType.name().toLowerCase(Locale.ROOT);
        if (!expected.equals(roleSegment)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Use strictly: <name>@student.com for Student, <name>@staff.com for Staff, <name>@system.com for System"
            );
        }
    }

    // Extracts role names for API response and JWT claims readability.
    private List<String> extractRoleNames(User user) {
        return user.getRole() == null ? List.of() : List.of(user.getRole().name());
    }

    // Checks if stored password looks like BCrypt hash.
    private static boolean isBcryptEncoded(String stored) {
        return stored.length() >= 4
                && stored.charAt(0) == '$'
                && (stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$"));
    }
}
