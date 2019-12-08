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
}