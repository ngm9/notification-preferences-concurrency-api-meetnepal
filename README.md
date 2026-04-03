# Notification Preferences API — Engineering Task

## Task Overview

You are working on the backend of a multi-tenant SaaS platform that lets enterprise customers manage notification preferences for their users. Each tenant is an isolated organization, and users within a tenant control how they receive notifications — via email, SMS, push, and at what frequency. The API is built with FastAPI and PostgreSQL and is already deployed, but two critical issues have been escalated from production: unauthenticated cross-tenant data access and silent data loss from concurrent writes. Both issues affect real customer data and must be resolved with production-grade correctness — not just patched.

## Objectives

- Enforce tenant-scoped access control on both read and write endpoints, correctly differentiating between regular users and admin users within a tenant
- Ensure that cross-tenant access is firmly and consistently rejected with the correct HTTP response, regardless of the requester's role
- Implement HTTP-level optimistic concurrency control on the preferences update endpoint, using standard conditional request headers to prevent silent data overwrites
- Ensure the API surfaces meaningful, semantically correct HTTP responses for all authorization and concurrency failure scenarios
- Produce clean, well-structured code with proper separation of concerns between routing, business logic, and data access

## How to Verify

- A regular user's GET and PUT requests for another user's preferences (within the same tenant) should be rejected with the appropriate HTTP status
- An admin user's GET and PUT requests for any user within the same tenant should succeed; requests targeting a user in a different tenant must be rejected
- A GET response for preferences must include an ETag header reflecting the current resource version
- A PUT request without an If-Match header must be explicitly rejected; a PUT with a stale If-Match value must also be rejected with the correct HTTP status
- A PUT request where the If-Match value matches the current version must succeed and the version must be incremented atomically
- Two concurrent PUT requests with the same original ETag value must result in one success and one rejection — no silent overwrites

## Helpful Tips

- Consider how JWT claims can serve as the authoritative source of identity and tenant membership — think about where this check belongs in your request lifecycle
- Think about what HTTP status codes most precisely communicate 'you are not allowed here' versus 'the resource has changed since you last read it'
- Explore how the ETag value should be generated and what properties it needs to have to be a reliable version identifier
- Review how conditional request headers (If-Match, If-None-Match) are defined in HTTP semantics and what server behavior the spec requires
- Think about where concurrency conflict detection should live — at the database layer, the service layer, or the route handler — and what the trade-offs are for each choice
