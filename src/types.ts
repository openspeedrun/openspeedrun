export default class JWTModel {
    token: string;
}

export interface Pronouns {
    subject: string;
    object: string;
    possesive: string;
}

export interface Social {
    name: string;
    link: string;
}

export interface UserInfo {
    id: string;
    display_name: string;
    profile_picture: string;
    verified: boolean;
    pronouns: Pronouns;
    pronouns_enabled: boolean;
    country: string;
    flavourText: string;
    social: Social[];
    powers: Power;
}

export enum Power {
    Webmaster = 1000,
    Admin = 100,
    Moderator = 10,
    User = 1,
    Banned = -1
}

export function powerLevelToString(powers: Power): string {
    switch(powers) {
        case 0: return "Banned";
        case 1: return "User";
        case 10: return "Mod";
        case 100: return "Admin";
        case 1000: return "Webmaster";
        default: return "error";
    }
}

export function powerLevelToCSS(powers: Power): string {
    switch(powers) {
        case 0: return "bg-banned";
        case 10: return "bg-mod";
        case 100: return "bg-admin";
        case 1000: return "bg-webmaster";
        default: return "";
    }
}