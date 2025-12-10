# .NET 8.0 LTS Migration Guide

This document describes the migration of the Zava Storefront application from .NET 6.0 to .NET 8.0 LTS (Long-Term Support).

## Overview

**Migration Date**: December 2025  
**Previous Version**: .NET 6.0  
**Current Version**: .NET 8.0 (LTS)  
**Migration Scope**: Framework upgrade with no breaking changes

## Why .NET 8.0?

- **Long-Term Support**: .NET 8.0 is an LTS release with support until November 2026
- **End of Support**: .NET 6.0 reached end of support and no longer receives security updates
- **Performance Improvements**: .NET 8.0 includes significant performance enhancements
- **Security Updates**: Ongoing security patches and updates from Microsoft
- **Modern Features**: Access to latest C# language features and runtime improvements

## Changes Made

### 1. Project File Update

**File**: `src/ZavaStorefront.csproj`

Changed the `TargetFramework` from `net6.0` to `net8.0`:

```xml
<PropertyGroup>
  <TargetFramework>net8.0</TargetFramework>
  <Nullable>enable</Nullable>
  <ImplicitUsings>enable</ImplicitUsings>
  <UserSecretsId>bf44e742-79e2-403b-85c4-070d9d765dd5</UserSecretsId>
</PropertyGroup>
```

### 2. Docker Image Update

**File**: `Dockerfile`

Updated Docker base images:
- Build stage: `mcr.microsoft.com/dotnet/sdk:6.0` → `mcr.microsoft.com/dotnet/sdk:8.0`
- Runtime stage: `mcr.microsoft.com/dotnet/aspnet:6.0` → `mcr.microsoft.com/dotnet/aspnet:8.0`

```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ./src/ZavaStorefront.sln ./
COPY ./src/ ./
RUN dotnet restore ZavaStorefront.csproj
RUN dotnet publish ZavaStorefront.csproj -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "ZavaStorefront.dll"]
```

### 3. Documentation Update

**File**: `src/README.md`

Updated references to .NET version from 6 to 8 in:
- Main description
- Technology Stack section

## Migration Steps Performed

1. **Identified Current Version**: Confirmed project was using .NET 6.0
2. **Updated Project File**: Modified `TargetFramework` to `net8.0` in `.csproj`
3. **Updated Docker Images**: Changed base images to .NET 8.0 SDK and runtime
4. **Restored Packages**: Ran `dotnet restore` to update dependencies
5. **Built Application**: Verified successful build with `dotnet build`
6. **Tested Application**: Confirmed application starts and runs correctly
7. **Docker Build**: Verified Docker image builds successfully
8. **Updated Documentation**: Reflected changes in project documentation

## Verification Results

### Build Status
✅ **Success** - Project builds without errors
- Only existing nullable reference warnings remain (pre-existing, not related to migration)
- No new warnings or errors introduced by the migration
- EOL warning for .NET 6.0 eliminated

### Runtime Status
✅ **Success** - Application runs correctly
- ASP.NET Core application starts successfully
- Listens on configured port (5000 in development, 8080 in Docker)
- All endpoints and routes function as expected

### Docker Status
✅ **Success** - Docker image builds and runs
- Multi-stage build completes successfully
- Image size and build time comparable to .NET 6.0 version
- Container starts and serves application correctly

## Breaking Changes

**None** - This migration had no breaking changes for this application.

The Zava Storefront application uses:
- Standard ASP.NET Core MVC features
- Session-based state management
- Bootstrap for UI components
- No external database dependencies
- No third-party packages requiring updates

All these components are fully compatible with .NET 8.0 without modifications.

## Known Issues

**None** - No issues encountered during or after migration.

The existing nullable reference warnings in the codebase are pre-existing and unrelated to the .NET version upgrade. These can be addressed separately if desired.

## Rollback Plan

If rollback is needed:

1. Revert `src/ZavaStorefront.csproj`:
   ```xml
   <TargetFramework>net6.0</TargetFramework>
   ```

2. Revert `Dockerfile`:
   ```dockerfile
   FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
   ...
   FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
   ```

3. Restore and rebuild:
   ```bash
   dotnet restore
   dotnet build
   ```

## Performance Notes

.NET 8.0 includes several performance improvements over .NET 6.0:
- Faster JIT compilation
- Improved garbage collection
- Better throughput for web applications
- Reduced memory allocation

For the Zava Storefront application, these improvements should result in slightly better response times and lower memory usage, though the differences may be minimal given the application's simplicity.

## Security Considerations

- ✅ .NET 8.0 receives regular security updates until November 2026
- ✅ No new security vulnerabilities introduced
- ✅ Continues to follow Microsoft security best practices
- ✅ All existing security features remain functional

## Next Steps

### Recommended Actions
1. ✅ Update CI/CD pipelines (if needed) - GitHub Actions workflow uses Azure Container Registry which handles .NET version automatically
2. ✅ Update deployment environments - Docker-based deployment automatically uses new images
3. ✅ Monitor application logs - No issues expected
4. ✅ Update team documentation - Completed with this guide

### Optional Improvements
- Consider adopting new .NET 8 features (Native AOT, improved minimal APIs, etc.)
- Review and address nullable reference warnings
- Explore new ASP.NET Core 8.0 features for future enhancements

## References

- [.NET 8 Release Notes](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-8/overview)
- [Migrate from ASP.NET Core 6.0 to 8.0](https://learn.microsoft.com/en-us/aspnet/core/migration/60-to-80)
- [.NET Support Policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core)
- [What's New in .NET 8](https://devblogs.microsoft.com/dotnet/announcing-dotnet-8/)

## Support

For issues or questions related to this migration:
1. Review this migration guide
2. Check the [.NET 8 documentation](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-8/)
3. Consult with the development team
4. Review build and runtime logs for specific error messages
