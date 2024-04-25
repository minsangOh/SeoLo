package com.c104.seolo.domain.user.entity;

import com.c104.seolo.domain.core.enums.Code;
import com.c104.seolo.domain.user.enums.Role;
import com.c104.seolo.global.common.BaseEntity;
import com.c104.seolo.headquarter.employee.entity.Employee;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.ToString;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Collection;
import java.util.Collections;

@ToString
@Getter
@Entity
@Table(name = "app_user")
public class User extends BaseEntity implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "employee_num", referencedColumnName = "employee_num", nullable = false)
    private Employee employee;

    @Column(name = "user_role", length = 30, nullable = false)
    @Enumerated(EnumType.STRING)
    private Role role;

    @Column(name = "user_stat", length = 15, nullable = false)
    @Enumerated(EnumType.STRING)
    private Code statusCode;

    @Column(name = "user_pwd", length = 72, nullable = false)
    private String password;

    @Column(name = "user_pin", length = 4, nullable = false)
    // 기본값으로 사용자의 '월일 ex 0223 으로 지정한다'
    private String PIN;

    @Column(name = "isLocked")
    private Boolean isLocked;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singletonList(new SimpleGrantedAuthority(this.role.name()));
    }

    @Override
    public String getUsername() {
        return this.employee.getEmployeeNum(); // 사번을 username 으로한다.
    }

    @Override
    public boolean isAccountNonExpired() {
        ZonedDateTime now = ZonedDateTime.now(ZoneId.of("Asia/Seoul"));
        
        if (employee.getEmployeeLeaveDate() == null) {
            // 퇴사날짜 없으면 만료안함
            return true;
        }
        // employeeLeaveDate를 Instant로 변환하고, 서울 시간대의 ZonedDateTime으로 변환
        ZonedDateTime leaveDateTime = employee.getEmployeeLeaveDate().toInstant()
                .atZone(ZoneId.of("Asia/Seoul"));

        // leaveDateTime이 now 이후이면 만료되지 않음, now 이전이면 만료됨
        return !leaveDateTime.isBefore(now);
    }

    @Override
    public boolean isAccountNonLocked() {
        return isLocked == null ? true : !isLocked;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    // JPA 프록시 객체 생성을 위한 기본생성자
    protected User() {}

    public static class Builder {
        private Employee employee;
        private Role role;
        private Code statusCode;
        private String password;
        private String PIN;
        private boolean isLocked = false;

        public Builder employee(Employee employee) {
            this.employee = employee;
            return this;
        }

        public Builder role(Role role) {
            this.role = role;
            return this;
        }

        public Builder statusCode(Code statusCode) {
            this.statusCode = statusCode;
            return this;
        }

        public Builder password(String password) {
            this.password = password;
            return this;
        }

        public Builder PIN(String PIN) {
            this.PIN = PIN;
            return this;
        }

        public Builder isLocked(Boolean isLocked) {
            this.isLocked = isLocked;
            return this;
        }

        public User build() {
            return new User(this);
        }
    }
    
    // 정적 팩토리 메서드
    public static Builder builder() {
        return new Builder();
    }

    // 빌더 생성자 -> 빌더 객체로부터 값을 받아 초기화
    public User(Builder builder) {
        this.employee = builder.employee;
        this.role = builder.role;
        this.statusCode = builder.statusCode;
        this.password = builder.password;
        this.PIN = builder.PIN;
        this.isLocked = builder.isLocked;
    }
}
