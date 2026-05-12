from rest_framework.permissions import BasePermission

from .models import StaffRole


class HasRole(BasePermission):
    allowed_roles: tuple[str, ...] = ()

    def has_permission(self, request, view) -> bool:
        profile = getattr(request.user, "staff_profile", None)
        if not request.user or not request.user.is_authenticated or profile is None:
            return False
        return profile.role in self.allowed_roles


class IsDirector(HasRole):
    allowed_roles = (StaffRole.DIRECTOR,)


class IsWaiter(HasRole):
    allowed_roles = (StaffRole.WAITER,)


class IsCashier(HasRole):
    allowed_roles = (StaffRole.CASHIER,)


class IsDirectorOrCashier(HasRole):
    allowed_roles = (StaffRole.DIRECTOR, StaffRole.CASHIER)


class IsRestaurantStaff(HasRole):
    allowed_roles = (StaffRole.WAITER, StaffRole.DIRECTOR, StaffRole.CASHIER)
