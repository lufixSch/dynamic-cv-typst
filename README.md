# Dynamic CV

Typst toolbox for dynamically generating CVs based on YAML files.

## Usage

First clone this repository in the directory where you want to create your CVs. To get started create four YAML files containing your _personal information_, _education_, _places you worked at_ and _skills_ with the following structure.

**Personal:**

```yaml
# Full name of the individual
name: John Doe

# Birth information (optional)
birth:
  # Date of birth
  date: "01.01.1980"
  # Place of birth, can be multiline
  place: |-
    New York City
    USA

# Citizenship (optional)
citizenship: United States

# Gender (optional)
gender: Male

# Address (optional), can be multiline
address: |-
  123 Main St
  Springfield
  IL 62704

# Phone number (optional)
phone: "+1 555 1234 567"

# Email address (optional)
email: "johndoe@example.com"
```

**Education or Work:**

```yaml
# List of Education/Work items
- title: "Bachelor of Science (BSc)"
  # Description (optional), can be multiline
  description: "Computer Science, University of Example"
  # Attendance dates
  date:
    # Start date
    start: "09/2015"
    # End date (optional)
    end: "07/2019"

- title: "Professional Certification in Data Analysis"
  # Custom date label
  date: "Custom date label"
```

**Skills:**

```yaml
# First skill category
- category: "Language Skills"

  # List of skills in that category
  items:
    # Name of the skill
    - name: English
      # Description or details, can be multiline
      description: Native speaker

# Second skill category
- category: "Computer Skills"

  # List of skills in that category
  items:
    # Name of the skill
    - name: Office Suite
      # Description or details, can be multiline
      description: |-
        Proficient in LaTeX, Typst.
        Familiar with LibreOffice and OpenOffice.
```

Naturally all YAML schemas can be extended with custom keys and values if needed.

Start your Typst document with the `cv` template.

```typ
#import "lib.typ": *

#show: cv.with(
  // Paths to your YAML files
  paths: (
    personal: "personal.yaml",
    education: "education.yaml",
    work: "work.yaml",
    skills: "skills.yaml",
  ),

  // Default column ratios for tables
  columns: (1fr, 3fr),

  // Language
  lang: de
)
```

Optionally you can also overwrite the default configuration with custom keywords (for example for a different language).

Afterward you have access to the `config` and `information` state variables to build your document.

```typ
#context config.get()
#context information.get()
```

This repo also provides some utility functions to make parsing of the YAML information easier.

## Examples

Minimal examples for different section of a CV.

### Personal Information

```typ
#context {
  let cfg = config.get().keywords
  let info = information.get().personal

  table(
    [#cfg.name:], info.name,
    [#cfg.address:], info.address,
    [#cfg.phone:], info.phone,
    [#cfg.email:], info.email,
    [#cfg.birthdate:], info.birth.date,
    [#cfg.birthplace:], info.birth.place,
    [#cfg.citizenship:], info.citizenship,
    [#cfg.gender:], info.gender
  )
}
```

### Education (Similar for Work)

```typ
#context {
  let cfg = config.get().keywords
  let info = information.get().education

  table(
    ..for i in info.rev() {
      (
        get_date(i.date),
        [#strong(i.title) #linebreak() #i.at("description", default: "")],
      )
    }
  )
}
```

### Skills

```typ
#context {
  let cfg = config.get().keywords
  let info = information.get().skills

  table(
    ..for c in info {
      (
        strong(c.category),"",
        ..for i in c.items {
          (
            i.name,
            i.description,

          )
        }
      )
    }
  )
}
```
