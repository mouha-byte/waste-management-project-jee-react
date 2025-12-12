import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

// Translations
const resources = {
    en: {
        translation: {
            "dashboard": "Dashboard",
            "points": "Collection Points",
            "employees": "Employees",
            "vehicles": "Vehicles",
            "routes": "Routes",
            "settings": "Settings",
            "logout": "Logout",
            "welcome": "Welcome",
            "darkMode": "Dark Mode",
            "lightMode": "Light Mode",
            "language": "Language",
            "stats": {
                "totalPoints": "Total Points",
                "activeRoutes": "Active Routes",
                "availableVehicles": "Available Vehicles",
                "onDuty": "On Duty"
            },
            "map": {
                "title": "Live Overview"
            },
            "actions": {
                "add": "Add New",
                "edit": "Edit",
                "delete": "Delete",
                "save": "Save",
                "cancel": "Cancel"
            }
        }
    },
    fr: {
        translation: {
            "dashboard": "Tableau de bord",
            "points": "Points de collecte",
            "employees": "Employés",
            "vehicles": "Véhicules",
            "routes": "Itinéraires",
            "settings": "Paramètres",
            "logout": "Déconnexion",
            "welcome": "Bienvenue",
            "darkMode": "Mode Sombre",
            "lightMode": "Mode Clair",
            "language": "Langue",
            "stats": {
                "totalPoints": "Points Totaux",
                "activeRoutes": "Itinéraires Actifs",
                "availableVehicles": "Véhicules Disponibles",
                "onDuty": "En Service"
            },
            "map": {
                "title": "Aperçu en direct"
            },
            "actions": {
                "add": "Ajouter",
                "edit": "Modifier",
                "delete": "Supprimer",
                "save": "Enregistrer",
                "cancel": "Annuler"
            }
        }
    },
    ar: {
        translation: {
            "dashboard": "لوحة القيادة",
            "points": "نقاط الجمع",
            "employees": "الموظفين",
            "vehicles": "المركبات",
            "routes": "المسارات",
            "settings": "الإعدادات",
            "logout": "تسجيل الخروج",
            "welcome": "مرحباً",
            "darkMode": "الوضع الداكن",
            "lightMode": "الوضع الفاتح",
            "language": "اللغة",
            "stats": {
                "totalPoints": "مجموع النقاط",
                "activeRoutes": "المسارات النشطة",
                "availableVehicles": "المركبات المتاحة",
                "onDuty": "في الخدمة"
            },
            "map": {
                "title": "نظرة عامة حية"
            },
            "actions": {
                "add": "إضافة جديد",
                "edit": "تعديل",
                "delete": "حذف",
                "save": "حفظ",
                "cancel": "إلغاء"
            }
        }
    }
};

i18n
    .use(initReactI18next)
    .init({
        resources,
        lng: "en", // default language
        interpolation: {
            escapeValue: false
        }
    });

export default i18n;
